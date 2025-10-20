import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - Colors
extension Color {
    static let exchangeBlue  = Color(red: 0.18, green: 0.52, blue: 0.98)
    static let exchangeGreen = Color(red: 0.10, green: 0.78, blue: 0.52)
    static let exchangeGold  = Color(red: 0.98, green: 0.80, blue: 0.20)
}

// MARK: - Safe Content Margins
extension View {
    @ViewBuilder
    func contentMarginsSafe(_ edges: Edge.Set = .all, _ length: CGFloat?, for _: AnyHashable? = nil) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
            self.contentMargins(edges, length)
        } else {
            self
        }
    }
}

// MARK: - Models
struct FinancialPlace: Identifiable {
    let id = UUID()
    let name: String
    let type: PlaceType
    let coordinate: CLLocationCoordinate2D
    let distance: CLLocationDistance
    
    enum PlaceType: String, CaseIterable {
        case bank = "bank"
        case atm = "atm"
        case exchange = "exchange"
        
        var localizedName: String {
            switch self {
            case .bank: return "bank_label".localized()
            case .atm: return "atm_label".localized()
            case .exchange: return "exchange_house".localized()
            }
        }
        
        var icon: String {
            switch self {
            case .bank: return "building.columns.fill"
            case .atm: return "banknote.fill"
            case .exchange: return "dollarsign.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .bank: return .exchangeBlue
            case .atm: return .exchangeGreen
            case .exchange: return .exchangeGold
            }
        }
    }
}

enum DistanceUnit: String, CaseIterable {
    case kilometers = "km"
    case miles = "mi"
    
    var factor: Double {
        switch self {
        case .kilometers: return 1.0
        case .miles: return 0.621371
        }
    }
    
    mutating func toggle() {
        self = self == .kilometers ? .miles : .kilometers
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            locationError = "Location access denied"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = location
            self.locationError = nil
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error.localizedDescription
            print("Location error: \(error.localizedDescription)")
        }
    }
}

// MARK: - ViewModel
@MainActor
class FinancialServicesViewModel: ObservableObject {
    @Published var places: [FinancialPlace] = []
    @Published var isLoading = false
    @Published var selectedType: FinancialPlace.PlaceType?
    @Published var distanceUnit: DistanceUnit = .kilometers
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
    )
    
    private var searchTask: Task<Void, Never>?
    
    var filteredPlaces: [FinancialPlace] {
        selectedType.map { type in places.filter { $0.type == type } } ?? places
    }
    
    func updateRegionToUserLocation(_ location: CLLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
    }
    
    func centerMapOnUserLocation(_ location: CLLocation,
                                latitudinalMeters: CLLocationDistance = 10000,
                                longitudinalMeters: CLLocationDistance = 10000) {
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: latitudinalMeters,
                longitudinalMeters: longitudinalMeters
            )
        }
    }
    
    func searchNearbyPlaces(userLocation: CLLocation, type: FinancialPlace.PlaceType?) {
        searchTask?.cancel()
        isLoading = true
        places.removeAll()
        
        let queries: [String]
        switch type {
        case .bank:
            queries = ["banco"]
        case .atm:
            queries = ["cajero automático", "ATM"]
        case .exchange:
            queries = ["casa de cambio"]
        case .none:
            queries = ["banco", "cajero automático", "ATM", "casa de cambio"]
        }
        
        let searchRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
        
        searchTask = Task {
            var collected: [FinancialPlace] = []
            
            await withTaskGroup(of: [FinancialPlace].self) { group in
                for query in Set(Self.sanitizeQueries(queries)) {
                    group.addTask { [searchRegion] in
                        await self.performSearch(query: query, region: searchRegion, userLocation: userLocation)
                    }
                }
                
                for await result in group {
                    collected.append(contentsOf: result)
                }
            }
            
            guard !Task.isCancelled else { return }
            
            let deduped = self.deduplicate(collected)
            self.places = deduped.sorted { $0.distance < $1.distance }
            self.isLoading = false
        }
    }
    
    private static func sanitizeQueries(_ queries: [String]) -> [String] {
        queries
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }
    
    private func performSearch(query: String, region: MKCoordinateRegion, userLocation: CLLocation) async -> [FinancialPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            var found: [FinancialPlace] = []
            
            for item in response.mapItems {
                let location = CLLocation(latitude: item.placemark.coordinate.latitude,
                                          longitude: item.placemark.coordinate.longitude)
                let distance = userLocation.distance(from: location)
                
                guard distance <= 10000 else { continue }
                
                let name = item.name ?? "Desconocido"
                let placeType = determinePlaceType(name: name)
                
                let place = FinancialPlace(
                    name: name,
                    type: placeType,
                    coordinate: item.placemark.coordinate,
                    distance: distance
                )
                found.append(place)
            }
            return found
        } catch {
            print("Search error for '\(query)': \(error.localizedDescription)")
            return []
        }
    }
    
    private func deduplicate(_ places: [FinancialPlace]) -> [FinancialPlace] {
        var seen = Set<String>()
        var result: [FinancialPlace] = []
        
        for place in places {
            let key = "\(place.name.lowercased())|\(round(place.coordinate.latitude * 10000)/10000)|\(round(place.coordinate.longitude * 10000)/10000)"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(place)
            }
        }
        return result
    }
    
    private func determinePlaceType(name: String) -> FinancialPlace.PlaceType {
        let lowercased = name.lowercased()
        if lowercased.contains("atm") || lowercased.contains("cajero") {
            return .atm
        } else if lowercased.contains("cambio") || lowercased.contains("exchange") {
            return .exchange
        } else {
            return .bank
        }
    }
    
    func formatDistance(_ distance: CLLocationDistance) -> String {
        let distanceInKm = distance / 1000
        let convertedDistance = distanceInKm * distanceUnit.factor
        
        if distanceUnit == .miles {
            // Convertir a pies si es menos de 0.1 millas
            if convertedDistance < 0.1 {
                let feet = distance * 3.28084
                return String(format: "%.0f ft", feet)
            } else {
                return String(format: "%.1f %@", convertedDistance, distanceUnit.rawValue)
            }
        } else {
            // Mostrar en metros si es menos de 1 km
            if convertedDistance < 1 {
                return String(format: "%.0f m", distance)
            } else {
                return String(format: "%.1f %@", convertedDistance, distanceUnit.rawValue)
            }
        }
    }
    
    func openInMaps(place: FinancialPlace) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Markets View
struct MarketsView: View {
    @StateObject private var viewModel = FinancialServicesViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var hasRequestedLocation = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                filterChipsView
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                mapView
                    .padding(.bottom, 12)
                
                placesList
            }
        }
        .navigationTitle("financial_services".localized())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                distanceButton
            }
        }
        .onAppear {
            if !hasRequestedLocation {
                locationManager.requestLocation()
                hasRequestedLocation = true
            }
        }
        .onChange(of: locationManager.userLocation) { _, newLocation in
            if let location = newLocation {
                withAnimation(.easeInOut(duration: 0.4)) {
                    viewModel.updateRegionToUserLocation(location)
                }
                viewModel.searchNearbyPlaces(userLocation: location, type: viewModel.selectedType)
            }
        }
    }
    
    private var distanceButton: some View {
        Button {
            viewModel.distanceUnit.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "ruler")
                    .font(.system(size: 14, weight: .semibold))
                Text(viewModel.distanceUnit.rawValue)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FinancialPlace.PlaceType.allCases, id: \.self) { type in
                    FilterChip(
                        isSelected: viewModel.selectedType == type,
                        title: type.localizedName,
                        systemImage: type.icon,
                        accent: type.color
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedType = viewModel.selectedType == type ? nil : type
                            if let location = locationManager.userLocation {
                                viewModel.searchNearbyPlaces(userLocation: location, type: viewModel.selectedType)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var mapView: some View {
        ZStack {
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: Array(viewModel.filteredPlaces.prefix(15))
            ) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    PlaceMarkerView(place: place)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
            )
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        if let location = locationManager.userLocation {
                            viewModel.centerMapOnUserLocation(location, latitudinalMeters: 2000, longitudinalMeters: 2000)
                        } else {
                            locationManager.requestLocation()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                            
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                        }
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(12)
                }
            }
        }
        .frame(height: 350)
        .padding(.horizontal, 16)
    }
    
    private var placesList: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("searching_places".localized())
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height)
                    } else if viewModel.filteredPlaces.isEmpty {
                        emptyStateView
                            .frame(height: geometry.size.height)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredPlaces) { place in
                                PlaceCardView(
                                    place: place,
                                    distance: viewModel.formatDistance(place.distance),
                                    onTap: { viewModel.openInMaps(place: place) }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(Color.appBackground)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("no_places_found".localized())
                .font(.headline)
                .foregroundColor(.appTextSecondary)
            Text("try_another_location".localized())
            
            if locationManager.authorizationStatus != .authorizedWhenInUse &&
               locationManager.authorizationStatus != .authorizedAlways {
                Button("enable_location".localized()) {
                    locationManager.requestLocation()
                }
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
    }
}

// MARK: - Place Marker View
struct PlaceMarkerView: View {
    let place: FinancialPlace
    @State private var showTooltip = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Tooltip
            if showTooltip {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: place.type.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(place.type.color)
                        
                        Text(place.name)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.appTextPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Text(place.type.localizedName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: 160)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(place.type.color.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                )
                .padding(.bottom, 4)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            
            // Marker
            ZStack {
                Circle()
                    .fill(place.type.color.opacity(0.25))
                    .frame(width: 36, height: 36)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(place.type.color, lineWidth: 2.5)
                    )
                
                Image(systemName: place.type.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(place.type.color)
            }
            .shadow(color: place.type.color.opacity(0.4), radius: 6, y: 2)
        }
        .fixedSize()
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showTooltip.toggle()
            }
            
            // Auto-hide después de 3 segundos
            if showTooltip {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showTooltip = false
                    }
                }
            }
        }
    }
}

// MARK: - Place Card View
struct PlaceCardView: View {
    let place: FinancialPlace
    let distance: String
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(place.type.color.opacity(0.5), lineWidth: 1.5)
                        )
                    
                    Image(systemName: place.type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(place.type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.body.weight(.medium))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundColor(place.type.color)
                        Text(place.type.localizedName)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(distance)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.appTextPrimary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(place.type.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let isSelected: Bool
    let title: String
    let systemImage: String
    let accent: Color
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(background)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var background: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(colorScheme == .dark ?
                Color.white.opacity(0.15) :
                Color.white)
        } else {
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return accent.opacity(0.6)
        } else {
            return Color.appTextPrimary.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return accent
        } else {
            return .appTextPrimary.opacity(0.7)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MarketsView()
            .preferredColorScheme(.dark)
    }
}
