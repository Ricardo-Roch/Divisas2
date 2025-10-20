import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configurar el delegado de notificaciones
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Mostrar notificaciones cuando la app está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Manejar tap en notificación
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

// MARK: - Notification Manager
class NotificationManager {
    static let shared = NotificationManager()
    
    private var lastKnownRate: Double {
        get {
            UserDefaults.standard.double(forKey: "lastKnownRate")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastKnownRate")
        }
    }
    
    private init() {}
    
    func scheduleHourlyNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // Programar notificación para cada hora del día
        for hour in 0..<24 {
            let content = UNMutableNotificationContent()
            content.title = "Tipo de Cambio USD/MXN"
            content.body = "Verificando tipo de cambio..."
            content.sound = .default
            content.categoryIdentifier = "EXCHANGE_RATE"
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "hourly-rate-\(hour)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification for hour \(hour): \(error)")
                }
            }
        }
        
        print("✅ Notificaciones programadas para cada hora")
    }
    
    func fetchAndNotifyRate() {
        let urlString = "https://api.frankfurter.app/latest?from=USD&to=MXN"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else { return }
            
            do {
                let result = try JSONDecoder().decode(FrankfurterLatestResponse.self, from: data)
                if let rate = result.rates["MXN"] {
                    self.sendNotification(for: rate)
                }
            } catch {
                print("Error fetching rate: \(error)")
            }
        }.resume()
    }
    
    private func sendNotification(for rate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "💱 Tipo de Cambio USD/MXN"
        content.body = "1 USD = $\(String(format: "%.2f", rate)) MXN"
        content.sound = .default
        
        // Calcular cambio porcentual si existe tasa anterior
        if lastKnownRate > 0 {
            let percentChange = ((rate - lastKnownRate) / lastKnownRate) * 100
            
            // Solo notificar cambios significativos (>1%)
            if abs(percentChange) >= 1.0 {
                let emoji = percentChange > 0 ? "📈" : "📉"
                let direction = percentChange > 0 ? "Subió" : "Bajó"
                content.subtitle = "\(emoji) \(direction) \(String(format: "%.2f", abs(percentChange)))% desde la última actualización"
            } else {
                content.subtitle = "Sin cambios significativos"
            }
        }
        
        // Guardar nueva tasa
        lastKnownRate = rate
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            } else {
                print("✅ Notificación enviada: $\(String(format: "%.2f", rate)) MXN")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("❌ Todas las notificaciones canceladas")
    }
}
