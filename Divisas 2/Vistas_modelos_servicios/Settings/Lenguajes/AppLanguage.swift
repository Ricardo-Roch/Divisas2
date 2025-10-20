//
//  AppLanguage.swift
//  Moneta
//
//  Created by Ricardo Rocha Moreno on 19/10/25.
//

import SwiftUI
import Combine

// MARK: - Idiomas Soportados
enum AppLanguage: String, CaseIterable, Codable {
    case spanish = "es"
    case english = "en"
    case french = "fr"
    case portuguese = "pt"
    case german = "de"
    case italian = "it"
    case chinese = "zh-Hans"
    case japanese = "ja"
    
    var displayName: String {
        switch self {
        case .spanish: return "Español"
        case .english: return "English"
        case .french: return "Français"
        case .portuguese: return "Português"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        }
    }
    
    var flag: String {
        switch self {
        case .spanish: return "🇪🇸"
        case .english: return "🇺🇸"
        case .french: return "🇫🇷"
        case .portuguese: return "🇧🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager3: ObservableObject {
    static let shared = LocalizationManager3()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language")
        self.currentLanguage = AppLanguage(rawValue: savedLanguage ?? "") ?? .spanish
    }
    
    func localizedString(_ key: String) -> String {
        return LocalizedStrings.get(key, language: currentLanguage)
    }
}

// MARK: - Strings Localizados
struct LocalizedStrings {
    static func get(_ key: String, language: AppLanguage) -> String {
        let translations: [String: [AppLanguage: String]] = [
            // HomeView
            "app_name": [
                .spanish: "Moneta",
                .english: "Moneta",
                .french: "Moneta",
                .portuguese: "Moneta",
                .german: "Moneta",
                .italian: "Moneta",
                .chinese: "Moneta",
                .japanese: "Moneta"
            ],
            "scanner_title": [
                .spanish: "Escáner",
                .english: "Scanner",
                .french: "Scanner",
                .portuguese: "Scanner",
                .german: "Scanner",
                .italian: "Scanner",
                .chinese: "扫描仪",
                .japanese: "スキャナー"
            ],
            "scanner_subtitle": [
                .spanish: "Identifica billetes y monedas",
                .english: "Identify bills and coins",
                .french: "Identifier les billets et pièces",
                .portuguese: "Identificar notas e moedas",
                .german: "Banknoten und Münzen identifizieren",
                .italian: "Identifica banconote e monete",
                .chinese: "识别钞票和硬币",
                .japanese: "紙幣とコインを識別"
            ],
            "scanner_cta": [
                .spanish: "¡DESCÚBRELO AHORA!",
                .english: "DISCOVER IT NOW!",
                .french: "DÉCOUVREZ-LE MAINTENANT!",
                .portuguese: "DESCUBRA AGORA!",
                .german: "JETZT ENTDECKEN!",
                .italian: "SCOPRILO ORA!",
                .chinese: "立即发现！",
                .japanese: "今すぐ発見！"
            ],
            "national_currency": [
                .spanish: "Divisa Nacional",
                .english: "National Currency",
                .french: "Monnaie Nationale",
                .portuguese: "Moeda Nacional",
                .german: "Landeswährung",
                .italian: "Valuta Nazionale",
                .chinese: "国家货币",
                .japanese: "国内通貨"
            ],
            "know_currencies": [
                .spanish: "Conoce las monedas",
                .english: "Know the currencies",
                .french: "Connaître les devises",
                .portuguese: "Conheça as moedas",
                .german: "Währungen kennen",
                .italian: "Conosci le valute",
                .chinese: "了解货币",
                .japanese: "通貨を知る"
            ],
            "exchange_money": [
                .spanish: "Cambia tu dinero",
                .english: "Exchange your money",
                .french: "Échangez votre argent",
                .portuguese: "Troque seu dinheiro",
                .german: "Geld wechseln",
                .italian: "Cambia i tuoi soldi",
                .chinese: "兑换您的钱",
                .japanese: "お金を両替"
            ],
            "nearby_locations": [
                .spanish: "Todo lo que está cerca de ti",
                .english: "Everything near you",
                .french: "Tout ce qui est près de vous",
                .portuguese: "Tudo perto de você",
                .german: "Alles in Ihrer Nähe",
                .italian: "Tutto vicino a te",
                .chinese: "您附近的一切",
                .japanese: "あなたの近くのすべて"
            ],
            "converter": [
                .spanish: "Convertidor",
                .english: "Converter",
                .french: "Convertisseur",
                .portuguese: "Conversor",
                .german: "Umrechner",
                .italian: "Convertitore",
                .chinese: "转换器",
                .japanese: "コンバーター"
            ],
            "between_currencies": [
                .spanish: "Entre monedas",
                .english: "Between currencies",
                .french: "Entre devises",
                .portuguese: "Entre moedas",
                .german: "Zwischen Währungen",
                .italian: "Tra valute",
                .chinese: "货币之间",
                .japanese: "通貨間"
            ],
            
            // SettingsView
            "settings": [
                .spanish: "Configuración",
                .english: "Settings",
                .french: "Paramètres",
                .portuguese: "Configurações",
                .german: "Einstellungen",
                .italian: "Impostazioni",
                .chinese: "设置",
                .japanese: "設定"
            ],
            "appearance": [
                .spanish: "Apariencia",
                .english: "Appearance",
                .french: "Apparence",
                .portuguese: "Aparência",
                .german: "Aussehen",
                .italian: "Aspetto",
                .chinese: "外观",
                .japanese: "外観"
            ],
            "appearance_desc": [
                .spanish: "Elige cómo quieres ver la aplicación. El modo Sistema se adapta a la configuración de tu dispositivo.",
                .english: "Choose how you want to see the app. System mode adapts to your device settings.",
                .french: "Choisissez comment vous voulez voir l'application. Le mode Système s'adapte aux paramètres de votre appareil.",
                .portuguese: "Escolha como deseja ver o aplicativo. O modo Sistema se adapta às configurações do seu dispositivo.",
                .german: "Wählen Sie, wie Sie die App sehen möchten. Der Systemmodus passt sich Ihren Geräteeinstellungen an.",
                .italian: "Scegli come vuoi vedere l'app. La modalità Sistema si adatta alle impostazioni del tuo dispositivo.",
                .chinese: "选择您想如何查看应用程序。系统模式适应您的设备设置。",
                .japanese: "アプリの表示方法を選択してください。システムモードはデバイスの設定に適応します。"
            ],
            "light": [
                .spanish: "Claro",
                .english: "Light",
                .french: "Clair",
                .portuguese: "Claro",
                .german: "Hell",
                .italian: "Chiaro",
                .chinese: "浅色",
                .japanese: "ライト"
            ],
            "dark": [
                .spanish: "Oscuro",
                .english: "Dark",
                .french: "Sombre",
                .portuguese: "Escuro",
                .german: "Dunkel",
                .italian: "Scuro",
                .chinese: "深色",
                .japanese: "ダーク"
            ],
            "system": [
                .spanish: "Sistema",
                .english: "System",
                .french: "Système",
                .portuguese: "Sistema",
                .german: "System",
                .italian: "Sistema",
                .chinese: "系统",
                .japanese: "システム"
            ],
            "language": [
                .spanish: "Idioma",
                .english: "Language",
                .french: "Langue",
                .portuguese: "Idioma",
                .german: "Sprache",
                .italian: "Lingua",
                .chinese: "语言",
                .japanese: "言語"
            ],
            "language_desc": [
                .spanish: "Selecciona el idioma de la aplicación. Los cambios se aplicarán inmediatamente.",
                .english: "Select the app language. Changes will apply immediately.",
                .french: "Sélectionnez la langue de l'application. Les modifications s'appliqueront immédiatement.",
                .portuguese: "Selecione o idioma do aplicativo. As alterações serão aplicadas imediatamente.",
                .german: "Wählen Sie die App-Sprache. Änderungen werden sofort übernommen.",
                .italian: "Seleziona la lingua dell'app. Le modifiche verranno applicate immediatamente.",
                .chinese: "选择应用语言。更改将立即应用。",
                .japanese: "アプリの言語を選択してください。変更はすぐに適用されます。"
            ],
            "notifications": [
                .spanish: "Notificaciones de Tipo de Cambio",
                .english: "Exchange Rate Notifications",
                .french: "Notifications de Taux de Change",
                .portuguese: "Notificações de Taxa de Câmbio",
                .german: "Wechselkurs-Benachrichtigungen",
                .italian: "Notifiche Tasso di Cambio",
                .chinese: "汇率通知",
                .japanese: "為替レート通知"
            ],
            "hourly_notification": [
                .spanish: "Notificación cada hora",
                .english: "Hourly notification",
                .french: "Notification horaire",
                .portuguese: "Notificação por hora",
                .german: "Stündliche Benachrichtigung",
                .italian: "Notifica oraria",
                .chinese: "每小时通知",
                .japanese: "毎時通知"
            ],
            "change_alert": [
                .spanish: "Alerta con cambios mayores al 1%",
                .english: "Alert for changes greater than 1%",
                .french: "Alerte pour changements supérieurs à 1%",
                .portuguese: "Alerta para mudanças maiores que 1%",
                .german: "Warnung bei Änderungen über 1%",
                .italian: "Avviso per variazioni superiori all'1%",
                .chinese: "变化超过1%时发出警报",
                .japanese: "1%以上の変化に対する警告"
            ],
            "current_rate": [
                .spanish: "Tipo de cambio actual",
                .english: "Current exchange rate",
                .french: "Taux de change actuel",
                .portuguese: "Taxa de câmbio atual",
                .german: "Aktueller Wechselkurs",
                .italian: "Tasso di cambio attuale",
                .chinese: "当前汇率",
                .japanese: "現在の為替レート"
            ],
            "notification_enabled_desc": [
                .spanish: "Recibirás notificaciones cada hora con el tipo de cambio USD/MXN actualizado.",
                .english: "You will receive hourly notifications with the updated USD/MXN exchange rate.",
                .french: "Vous recevrez des notifications horaires avec le taux de change USD/MXN mis à jour.",
                .portuguese: "Você receberá notificações a cada hora com a taxa de câmbio USD/MXN atualizada.",
                .german: "Sie erhalten stündliche Benachrichtigungen mit dem aktualisierten USD/MXN-Wechselkurs.",
                .italian: "Riceverai notifiche orarie con il tasso di cambio USD/MXN aggiornato.",
                .chinese: "您将每小时收到更新的美元/墨西哥比索汇率通知。",
                .japanese: "USD/MXNの更新された為替レートの通知を毎時受け取ります。"
            ],
            "notification_disabled_desc": [
                .spanish: "Activa las notificaciones para recibir actualizaciones del tipo de cambio.",
                .english: "Enable notifications to receive exchange rate updates.",
                .french: "Activez les notifications pour recevoir les mises à jour du taux de change.",
                .portuguese: "Ative as notificações para receber atualizações da taxa de câmbio.",
                .german: "Aktivieren Sie Benachrichtigungen, um Wechselkurs-Updates zu erhalten.",
                .italian: "Attiva le notifiche per ricevere aggiornamenti sul tasso di cambio.",
                .chinese: "启用通知以接收汇率更新。",
                .japanese: "為替レートの更新を受け取るには、通知を有効にしてください。"
            ],
            "notification_permission": [
                .spanish: "Permiso de Notificaciones",
                .english: "Notification Permission",
                .french: "Permission de Notification",
                .portuguese: "Permissão de Notificação",
                .german: "Benachrichtigungsberechtigung",
                .italian: "Permesso di Notifica",
                .chinese: "通知权限",
                .japanese: "通知許可"
            ],
            "notification_permission_desc": [
                .spanish: "Para recibir notificaciones del tipo de cambio, necesitas habilitar los permisos en Ajustes.",
                .english: "To receive exchange rate notifications, you need to enable permissions in Settings.",
                .french: "Pour recevoir des notifications de taux de change, vous devez activer les autorisations dans Paramètres.",
                .portuguese: "Para receber notificações de taxa de câmbio, você precisa habilitar permissões nas Configurações.",
                .german: "Um Wechselkursbenachrichtigungen zu erhalten, müssen Sie Berechtigungen in den Einstellungen aktivieren.",
                .italian: "Per ricevere notifiche sul tasso di cambio, devi abilitare i permessi nelle Impostazioni.",
                .chinese: "要接收汇率通知，您需要在设置中启用权限。",
                .japanese: "為替レート通知を受け取るには、設定で権限を有効にする必要があります。"
            ],
            "open_settings": [
                .spanish: "Abrir Ajustes",
                .english: "Open Settings",
                .french: "Ouvrir Paramètres",
                .portuguese: "Abrir Configurações",
                .german: "Einstellungen öffnen",
                .italian: "Apri Impostazioni",
                .chinese: "打开设置",
                .japanese: "設定を開く"
            ],
            "cancel": [
                .spanish: "Cancelar",
                .english: "Cancel",
                .french: "Annuler",
                .portuguese: "Cancelar",
                .german: "Abbrechen",
                .italian: "Annulla",
                .chinese: "取消",
                .japanese: "キャンセル"
            ]
        ]
        
        return translations[key]?[language] ?? key
    }
}

// MARK: - Extension para usar en Views
extension String {
    func localized() -> String {
        return LocalizationManager3.shared.localizedString(self)
    }
}
