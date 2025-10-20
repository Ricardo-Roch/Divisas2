import SwiftUI
import UserNotifications
import BackgroundTasks

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
        
        print("📅 Programando notificaciones horarias con datos reales de la API...")
        
        // Programar notificación para cada hora del día
        for hour in 0..<24 {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Crear una solicitud que ejecutará la obtención de datos
            let content = UNMutableNotificationContent()
            content.title = "💱 Tipo de Cambio USD/MXN"
            content.body = "Obteniendo tipo de cambio actual..."
            content.sound = .default
            content.categoryIdentifier = "EXCHANGE_RATE"
            content.userInfo = ["shouldFetchRate": true]
            
            let request = UNNotificationRequest(
                identifier: "hourly-rate-\(hour)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Error programando notificación para hora \(hour): \(error)")
                } else {
                    print("✅ Notificación programada para las \(hour):00")
                }
            }
        }
        
        // Enviar una notificación inmediata con el tipo de cambio actual
        fetchAndNotifyRate()
        
        print("✅ Sistema de notificaciones configurado correctamente")
    }
    
    func fetchAndNotifyRate() {
        print("🔄 Obteniendo tipo de cambio desde la API...")
        
        let urlString = "https://api.frankfurter.app/latest?from=USD&to=MXN"
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error en la petición: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No se recibieron datos")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(FrankfurterLatestResponse.self, from: data)
                if let rate = result.rates["MXN"] {
                    print("✅ Tipo de cambio obtenido: $\(String(format: "%.2f", rate)) MXN")
                    self.sendNotification(for: rate)
                } else {
                    print("❌ No se encontró el tipo de cambio MXN en la respuesta")
                }
            } catch {
                print("❌ Error decodificando respuesta: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func sendNotification(for rate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "💱 Tipo de Cambio USD/MXN"
        content.body = "1 USD = $\(String(format: "%.4f", rate)) MXN"
        content.sound = .default
        content.badge = 1
        
        // Calcular cambio porcentual si existe tasa anterior
        if lastKnownRate > 0 {
            let percentChange = ((rate - lastKnownRate) / lastKnownRate) * 100
            let change = rate - lastKnownRate
            
            // Mostrar cambio si es mayor a 0.5%
            if abs(percentChange) >= 0.5 {
                let emoji = percentChange > 0 ? "📈" : "📉"
                let direction = percentChange > 0 ? "Subió" : "Bajó"
                let changeSign = change > 0 ? "+" : ""
                
                content.subtitle = "\(emoji) \(direction) \(String(format: "%.2f", abs(percentChange)))%"
                content.body += "\n\(changeSign)$\(String(format: "%.4f", change)) MXN desde la última actualización"
                
                print("📊 Cambio detectado: \(direction) \(String(format: "%.2f", abs(percentChange)))%")
            } else {
                content.subtitle = "📊 Estable - Sin cambios significativos"
                print("📊 Sin cambios significativos")
            }
        } else {
            content.subtitle = "📊 Primera actualización del día"
            print("📊 Primera actualización registrada")
        }
        
        // Guardar nueva tasa
        lastKnownRate = rate
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastUpdateTime")
        
        // Crear la notificación
        let request = UNNotificationRequest(
            identifier: "exchange-rate-\(UUID().uuidString)",
            content: content,
            trigger: nil // Se envía inmediatamente
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error enviando notificación: \(error.localizedDescription)")
            } else {
                print("✅ Notificación enviada exitosamente: $\(String(format: "%.4f", rate)) MXN")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        lastKnownRate = 0
        UserDefaults.standard.removeObject(forKey: "lastUpdateTime")
        print("❌ Todas las notificaciones canceladas y datos limpiados")
    }
}
