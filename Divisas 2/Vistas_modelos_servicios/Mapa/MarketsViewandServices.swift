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
            case .bank: return "Banco"
            case .atm: return "ATM"
            case .exchange: return "Casa de Cambio"
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
        let convertedDistance = distance / 1000 * distanceUnit.factor
        if convertedDistance < 1 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f %@", convertedDistance, distanceUnit.rawValue)
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
        VStack(spacing: 0) {
            headerView
            Spacer(minLength: 4)
            mapView
            placesList
        }
        .navigationTitle("Financial Services")
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
        .background(Color.appBackground) // fondo adaptativo
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
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color.appCardBackground)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var headerView: some View {
        HStack {
            Spacer(minLength: 0)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(FinancialPlace.PlaceType.allCases, id: \.self) { type in
                        GlassChip(
                            isSelected: viewModel.selectedType == type,
                            title: type.localizedName,
                            systemImage: type.icon,
                            accent: type.color,
                            height: 36
                        ) {
                            viewModel.selectedType = viewModel.selectedType == type ? nil : type
                            if let location = locationManager.userLocation {
                                viewModel.searchNearbyPlaces(userLocation: location, type: viewModel.selectedType)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }
    
    private func markerLabel(for index: Int) -> String {
        index < 26 ? String(UnicodeScalar(65 + index)!) : String(index - 25)
    }
    
    private var mapView: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.35), radius: 14, y: 8)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    GlassCircleButton(systemImage: "location.fill") {
                        if let location = locationManager.userLocation {
                            viewModel.centerMapOnUserLocation(location, latitudinalMeters: 2000, longitudinalMeters: 2000)
                        } else {
                            locationManager.requestLocation()
                        }
                    }
                    .padding(12)
                }
            }
        }
        .frame(height: 350)
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private var placesList: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Searching for places...")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            } else if viewModel.filteredPlaces.isEmpty {
                emptyStateView
                    .padding(.top, 12)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(Array(viewModel.filteredPlaces.enumerated()), id: \.element.id) { index, place in
                        PlaceCardView(
                            place: place,
                            markerLabel: markerLabel(for: index),
                            distance: viewModel.formatDistance(place.distance),
                            onTap: { viewModel.openInMaps(place: place) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color.appBackground)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No places found")
                .font(.headline)
                .foregroundColor(.appTextSecondary)
            Text("Try a different location or enable location services.")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if locationManager.authorizationStatus != .authorizedWhenInUse &&
               locationManager.authorizationStatus != .authorizedAlways {
                Button("Enable Location") {
                    locationManager.requestLocation()
                }
                .padding()
                .background(Color.appCardBackground)
                .foregroundColor(.appTextPrimary)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
    }
}

// MARK: - Place Card View
struct PlaceCardView: View {
    let place: FinancialPlace
    let markerLabel: String
    let distance: String
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(place.type.color.opacity(0.6), lineWidth: 1))
                    Text(markerLabel)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.appTextPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.body.weight(.medium))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(2)
                    Text(place.type.localizedName)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(distance)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.appTextPrimary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LiquidGlassBackground(accent: place.type.color, tintOpacity: 0.26)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            )
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(place.type.color.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - GlassChip
struct GlassChip: View {
    let isSelected: Bool
    let title: String
    let systemImage: String
    let accent: Color
    var selectedTint: Double = 0.32
    var normalTint: Double = 0.22
    var height: CGFloat = 36
    let action: () -> Void
    
    @GestureState private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .foregroundColor(.appTextPrimary)
            .padding(.horizontal, 12)
            .frame(height: height)
            .background(
                LiquidGlassBackground(
                    accent: accent,
                    tintOpacity: isSelected ? selectedTint : normalTint
                )
                .clipShape(Capsule())
            )
            .overlay(Capsule().stroke(accent.opacity(isSelected ? 0.65 : 0.35), lineWidth: 1))
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in state = true }
        )
    }
}

// MARK: - LiquidGlassBackground
struct LiquidGlassBackground: View {
    var accent: Color
    var tintOpacity: Double = 0.22
    var shineOpacity: Double = 0.18
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(accent.opacity(tintOpacity))
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - GlassCircleButton
struct GlassCircleButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                )
                .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MarketsView()
            .preferredColorScheme(.dark) // Solo preview, la app hereda el esquema global
    }
}
