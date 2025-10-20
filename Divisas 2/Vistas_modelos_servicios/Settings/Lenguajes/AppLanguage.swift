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
            objectWillChange.send()
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
            // MARK: - HomeView
            "app_name": universalTranslation("Moneta"),
            
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
            
            // MARK: - SettingsView
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
            ],
            
            // MARK: - CurrencyConverterView
            "converter_title": [
                .spanish: "Conversor",
                .english: "Converter",
                .french: "Convertisseur",
                .portuguese: "Conversor",
                .german: "Umrechner",
                .italian: "Convertitore",
                .chinese: "转换器",
                .japanese: "コンバーター"
            ],
            "history": [
                .spanish: "Historial",
                .english: "History",
                .french: "Historique",
                .portuguese: "Histórico",
                .german: "Verlauf",
                .italian: "Cronologia",
                .chinese: "历史",
                .japanese: "履歴"
            ],
            "select_currency": [
                .spanish: "Seleccionar moneda",
                .english: "Select currency",
                .french: "Sélectionner la devise",
                .portuguese: "Selecionar moeda",
                .german: "Währung auswählen",
                .italian: "Seleziona valuta",
                .chinese: "选择货币",
                .japanese: "通貨を選択"
            ],
            "search_currency": [
                .spanish: "Buscar moneda",
                .english: "Search currency",
                .french: "Rechercher une devise",
                .portuguese: "Buscar moeda",
                .german: "Währung suchen",
                .italian: "Cerca valuta",
                .chinese: "搜索货币",
                .japanese: "通貨を検索"
            ],
            "close": [
                .spanish: "Cerrar",
                .english: "Close",
                .french: "Fermer",
                .portuguese: "Fechar",
                .german: "Schließen",
                .italian: "Chiudi",
                .chinese: "关闭",
                .japanese: "閉じる"
            ],
            "no_history": [
                .spanish: "Sin historial",
                .english: "No history",
                .french: "Pas d'historique",
                .portuguese: "Sem histórico",
                .german: "Kein Verlauf",
                .italian: "Nessuna cronologia",
                .chinese: "没有历史",
                .japanese: "履歴なし"
            ],
            "conversions_appear_here": [
                .spanish: "Tus conversiones aparecerán aquí",
                .english: "Your conversions will appear here",
                .french: "Vos conversions apparaîtront ici",
                .portuguese: "Suas conversões aparecerão aqui",
                .german: "Ihre Umrechnungen erscheinen hier",
                .italian: "Le tue conversioni appariranno qui",
                .chinese: "您的转换将显示在这里",
                .japanese: "変換履歴がここに表示されます"
            ],
            "rate": [
                .spanish: "Tasa",
                .english: "Rate",
                .french: "Taux",
                .portuguese: "Taxa",
                .german: "Kurs",
                .italian: "Tasso",
                .chinese: "汇率",
                .japanese: "レート"
            ],
            
            // MARK: - IdentificadorView
            "detecting": [
                .spanish: "Detectando",
                .english: "Detecting",
                .french: "Détection",
                .portuguese: "Detectando",
                .german: "Erkennung",
                .italian: "Rilevamento",
                .chinese: "检测中",
                .japanese: "検出中"
            ],
            "bills": [
                .spanish: "Billetes",
                .english: "Bills",
                .french: "Billets",
                .portuguese: "Notas",
                .german: "Banknoten",
                .italian: "Banconote",
                .chinese: "钞票",
                .japanese: "紙幣"
            ],
            "coins": [
                .spanish: "Monedas",
                .english: "Coins",
                .french: "Pièces",
                .portuguese: "Moedas",
                .german: "Münzen",
                .italian: "Monete",
                .chinese: "硬币",
                .japanese: "コイン"
            ],
            "analyzing": [
                .spanish: "Analizando",
                .english: "Analyzing",
                .french: "Analyse",
                .portuguese: "Analisando",
                .german: "Analysieren",
                .italian: "Analizzando",
                .chinese: "分析中",
                .japanese: "分析中"
            ],
            "identified": [
                .spanish: "✅ Identificado",
                .english: "✅ Identified",
                .french: "✅ Identifié",
                .portuguese: "✅ Identificado",
                .german: "✅ Identifiziert",
                .italian: "✅ Identificato",
                .chinese: "✅ 已识别",
                .japanese: "✅ 識別されました"
            ],
            "low_confidence": [
                .spanish: "⚠️ Confianza baja",
                .english: "⚠️ Low confidence",
                .french: "⚠️ Faible confiance",
                .portuguese: "⚠️ Confiança baixa",
                .german: "⚠️ Geringe Sicherheit",
                .italian: "⚠️ Bassa confidenza",
                .chinese: "⚠️ 置信度低",
                .japanese: "⚠️ 信頼度が低い"
            ],
            "confidence": [
                .spanish: "Confianza",
                .english: "Confidence",
                .french: "Confiance",
                .portuguese: "Confiança",
                .german: "Sicherheit",
                .italian: "Confidenza",
                .chinese: "置信度",
                .japanese: "信頼度"
            ],
            "camera_permission_required": [
                .spanish: "Permiso de Cámara Requerido",
                .english: "Camera Permission Required",
                .french: "Permission de caméra requise",
                .portuguese: "Permissão de Câmera Necessária",
                .german: "Kameraerlaubnis erforderlich",
                .italian: "Permesso fotocamera richiesto",
                .chinese: "需要相机权限",
                .japanese: "カメラの許可が必要です"
            ],
            "camera_permission_desc": [
                .spanish: "Esta app necesita acceso a la cámara para identificar billetes y monedas. Por favor, habilita el acceso en Ajustes.",
                .english: "This app needs camera access to identify bills and coins. Please enable access in Settings.",
                .french: "Cette application a besoin d'accéder à la caméra pour identifier les billets et les pièces. Veuillez activer l'accès dans Paramètres.",
                .portuguese: "Este aplicativo precisa de acesso à câmera para identificar notas e moedas. Por favor, habilite o acesso nas Configurações.",
                .german: "Diese App benötigt Kamerazugriff, um Banknoten und Münzen zu identifizieren. Bitte aktivieren Sie den Zugriff in den Einstellungen.",
                .italian: "Questa app ha bisogno dell'accesso alla fotocamera per identificare banconote e monete. Abilita l'accesso nelle Impostazioni.",
                .chinese: "此应用需要访问相机以识别钞票和硬币。请在设置中启用访问权限。",
                .japanese: "このアプリは紙幣とコインを識別するためにカメラへのアクセスが必要です。設定でアクセスを有効にしてください。"
            ],
            "ok": [
                .spanish: "OK",
                .english: "OK",
                .french: "OK",
                .portuguese: "OK",
                .german: "OK",
                .italian: "OK",
                .chinese: "确定",
                .japanese: "OK"
            ],
            // MARK: - MarketsView
            "financial_services": [
                .spanish: "Servicios Financieros",
                .english: "Financial Services",
                .french: "Services Financiers",
                .portuguese: "Serviços Financeiros",
                .german: "Finanzdienstleistungen",
                .italian: "Servizi Finanziari",
                .chinese: "金融服务",
                .japanese: "金融サービス"
            ],
            "searching_places": [
                .spanish: "Buscando lugares...",
                .english: "Searching places...",
                .french: "Recherche de lieux...",
                .portuguese: "Procurando lugares...",
                .german: "Orte suchen...",
                .italian: "Cercando luoghi...",
                .chinese: "搜索地点...",
                .japanese: "場所を検索中..."
            ],
            "no_places_found": [
                .spanish: "No se encontraron lugares",
                .english: "No places found",
                .french: "Aucun lieu trouvé",
                .portuguese: "Nenhum lugar encontrado",
                .german: "Keine Orte gefunden",
                .italian: "Nessun luogo trovato",
                .chinese: "未找到地点",
                .japanese: "場所が見つかりません"
            ],
            "try_another_location": [
                .spanish: "Intenta con otra ubicación o habilita los servicios de localización.",
                .english: "Try another location or enable location services.",
                .french: "Essayez un autre emplacement ou activez les services de localisation.",
                .portuguese: "Tente outro local ou ative os serviços de localização.",
                .german: "Versuchen Sie einen anderen Standort oder aktivieren Sie die Ortungsdienste.",
                .italian: "Prova un'altra posizione o abilita i servizi di localizzazione.",
                .chinese: "尝试其他位置或启用定位服务。",
                .japanese: "別の場所を試すか、位置情報サービスを有効にしてください。"
            ],
            "enable_location": [
                .spanish: "Habilitar Ubicación",
                .english: "Enable Location",
                .french: "Activer la localisation",
                .portuguese: "Ativar Localização",
                .german: "Standort aktivieren",
                .italian: "Abilita Posizione",
                .chinese: "启用定位",
                .japanese: "位置情報を有効にする"
            ],
            "bank_label": [
                .spanish: "Banco",
                .english: "Bank",
                .french: "Banque",
                .portuguese: "Banco",
                .german: "Bank",
                .italian: "Banca",
                .chinese: "银行",
                .japanese: "銀行"
            ],
            "atm_label": [
                .spanish: "ATM",
                .english: "ATM",
                .french: "GAB",
                .portuguese: "Caixa Eletrônico",
                .german: "Geldautomat",
                .italian: "Bancomat",
                .chinese: "自动取款机",
                .japanese: "ATM"
            ],
            "exchange_house": [
                .spanish: "Casa de Cambio",
                .english: "Exchange House",
                .french: "Bureau de Change",
                .portuguese: "Casa de Câmbio",
                .german: "Wechselstube",
                .italian: "Ufficio Cambio",
                .chinese: "货币兑换处",
                .japanese: "両替所"
            ],
            // MARK: - NationalCurrencyView & MexicanCoinDetailView
            "national_currencies": [
                .spanish: "Divisas Nacional",
                .english: "National Currency",
                .french: "Monnaie Nationale",
                .portuguese: "Moeda Nacional",
                .german: "Landeswährung",
                .italian: "Valuta Nazionale",
                .chinese: "国家货币",
                .japanese: "国内通貨"
            ],
            "choose_currency": [
                .spanish: "Elige la moneda de tu preferencia que desees conocer",
                .english: "Choose the currency you want to know",
                .french: "Choisissez la devise que vous souhaitez connaître",
                .portuguese: "Escolha a moeda que deseja conhecer",
                .german: "Wählen Sie die Währung, die Sie kennenlernen möchten",
                .italian: "Scegli la valuta che vuoi conoscere",
                .chinese: "选择您想了解的货币",
                .japanese: "知りたい通貨を選択してください"
            ],
            "mexican_peso": [
                .spanish: "Peso Mexicano",
                .english: "Mexican Peso",
                .french: "Peso Mexicain",
                .portuguese: "Peso Mexicano",
                .german: "Mexikanischer Peso",
                .italian: "Peso Messicano",
                .chinese: "墨西哥比索",
                .japanese: "メキシコペソ"
            ],
            "us_dollar": [
                .spanish: "Dólar Estadounidense",
                .english: "US Dollar",
                .french: "Dollar Américain",
                .portuguese: "Dólar Americano",
                .german: "US-Dollar",
                .italian: "Dollaro Americano",
                .chinese: "美元",
                .japanese: "米ドル"
            ],
            "canadian_dollar": [
                .spanish: "Dólar Canadiense",
                .english: "Canadian Dollar",
                .french: "Dollar Canadien",
                .portuguese: "Dólar Canadense",
                .german: "Kanadischer Dollar",
                .italian: "Dollaro Canadese",
                .chinese: "加元",
                .japanese: "カナダドル"
            ],
            "characteristics": [
                .spanish: "Características",
                .english: "Characteristics",
                .french: "Caractéristiques",
                .portuguese: "Características",
                .german: "Eigenschaften",
                .italian: "Caratteristiche",
                .chinese: "特征",
                .japanese: "特性"
            ],
            "issuer": [
                .spanish: "Emisor",
                .english: "Issuer",
                .french: "Émetteur",
                .portuguese: "Emissor",
                .german: "Emittent",
                .italian: "Emittente",
                .chinese: "发行人",
                .japanese: "発行者"
            ],
            "years": [
                .spanish: "Años",
                .english: "Years",
                .french: "Années",
                .portuguese: "Anos",
                .german: "Jahre",
                .italian: "Anni",
                .chinese: "年份",
                .japanese: "年"
            ],
            "value": [
                .spanish: "Valor",
                .english: "Value",
                .french: "Valeur",
                .portuguese: "Valor",
                .german: "Wert",
                .italian: "Valore",
                .chinese: "价值",
                .japanese: "価値"
            ],
            "information": [
                .spanish: "Información",
                .english: "Information",
                .french: "Information",
                .portuguese: "Informação",
                .german: "Information",
                .italian: "Informazione",
                .chinese: "信息",
                .japanese: "情報"
            ],
            "description": [
                .spanish: "Descripción",
                .english: "Description",
                .french: "Description",
                .portuguese: "Descrição",
                .german: "Beschreibung",
                .italian: "Descrizione",
                .chinese: "描述",
                .japanese: "説明"
            ],
            "details": [
                .spanish: "Detalles",
                .english: "Details",
                .french: "Détails",
                .portuguese: "Detalhes",
                .german: "Details",
                .italian: "Dettagli",
                .chinese: "详情",
                .japanese: "詳細"
            ],
            "nominal_value": [
                .spanish: "Valor nominal",
                .english: "Nominal value",
                .french: "Valeur nominale",
                .portuguese: "Valor nominal",
                .german: "Nennwert",
                .italian: "Valore nominale",
                .chinese: "面值",
                .japanese: "額面価値"
            ],
            "period": [
                .spanish: "Período",
                .english: "Period",
                .french: "Période",
                .portuguese: "Período",
                .german: "Zeitraum",
                .italian: "Periodo",
                .chinese: "时期",
                .japanese: "期間"
            ],
            "issuing_country": [
                .spanish: "País emisor",
                .english: "Issuing country",
                .french: "Pays émetteur",
                .portuguese: "País emissor",
                .german: "Ausstellendes Land",
                .italian: "Paese emittente",
                .chinese: "发行国",
                .japanese: "発行国"
            ],
            "type": [
                .spanish: "Tipo",
                .english: "Type",
                .french: "Type",
                .portuguese: "Tipo",
                .german: "Typ",
                .italian: "Tipo",
                .chinese: "类型",
                .japanese: "タイプ"
            ],
            "coin": [
                .spanish: "Moneda",
                .english: "Coin",
                .french: "Pièce",
                .portuguese: "Moeda",
                .german: "Münze",
                .italian: "Moneta",
                .chinese: "硬币",
                .japanese: "硬貨"
            ],
            "bill": [
                .spanish: "Billete",
                .english: "Bill",
                .french: "Billet",
                .portuguese: "Nota",
                .german: "Banknote",
                .italian: "Banconota",
                .chinese: "纸币",
                .japanese: "紙幣"
            ],
            // MARK: - MexCurrenciesListView
            "coins_and_bills": [
                .spanish: "Monedas y Billetes",
                .english: "Coins and Bills",
                .french: "Pièces et Billets",
                .portuguese: "Moedas e Notas",
                .german: "Münzen und Scheine",
                .italian: "Monete e Banconote",
                .chinese: "硬币和纸币",
                .japanese: "コインと紙幣"
            ],
            "search_coin_or_bill": [
                .spanish: "Buscar moneda o billete",
                .english: "Search coin or bill",
                .french: "Rechercher pièce ou billet",
                .portuguese: "Buscar moeda ou nota",
                .german: "Münze oder Schein suchen",
                .italian: "Cerca moneta o banconota",
                .chinese: "搜索硬币或纸币",
                .japanese: "コインまたは紙幣を検索"
            ],
            "search_any_currency": [
                .spanish: "Busca cualquier moneda de México en circulación actualmente",
                .english: "Search any currency of Mexico currently in circulation",
                .french: "Recherchez n'importe quelle devise du Mexique actuellement en circulation",
                .portuguese: "Procure qualquer moeda do México atualmente em circulação",
                .german: "Suchen Sie eine beliebige Währung Mexikos, die derzeit im Umlauf ist",
                .italian: "Cerca qualsiasi valuta del Messico attualmente in circolazione",
                .chinese: "搜索墨西哥目前流通的任何货币",
                .japanese: "メキシコで現在流通している通貨を検索"
            ],
            "no_results_found": [
                .spanish: "No se encontraron resultados",
                .english: "No results found",
                .french: "Aucun résultat trouvé",
                .portuguese: "Nenhum resultado encontrado",
                .german: "Keine Ergebnisse gefunden",
                .italian: "Nessun risultato trovato",
                .chinese: "未找到结果",
                .japanese: "結果が見つかりません"
            ],
            "try_another_search": [
                .spanish: "Intenta con otro término de búsqueda",
                .english: "Try another search term",
                .french: "Essayez un autre terme de recherche",
                .portuguese: "Tente outro termo de pesquisa",
                .german: "Versuchen Sie einen anderen Suchbegriff",
                .italian: "Prova un altro termine di ricerca",
                .chinese: "尝试其他搜索词",
                .japanese: "別の検索語を試してください"
            ],
            "mexican_coin_cents": [
                .spanish: "Moneda de {value} centavos mexicanos",
                .english: "{value} cents Mexican coin",
                .french: "Pièce de {value} centimes mexicains",
                .portuguese: "Moeda de {value} centavos mexicanos",
                .german: "{value} Centavos mexikanische Münze",
                .italian: "Moneta da {value} centesimi messicani",
                .chinese: "{value}分墨西哥硬币",
                .japanese: "メキシコ{value}センタボス硬貨"
            ],
            "mexican_coin_peso": [
                .spanish: "Moneda de {value} peso mexicano",
                .english: "{value} peso Mexican coin",
                .french: "Pièce de {value} peso mexicain",
                .portuguese: "Moeda de {value} peso mexicano",
                .german: "{value} Peso mexikanische Münze",
                .italian: "Moneta da {value} peso messicano",
                .chinese: "{value}比索墨西哥硬币",
                .japanese: "メキシコ{value}ペソ硬貨"
            ],
            "mexican_coin_pesos": [
                .spanish: "Moneda de {value} pesos mexicanos",
                .english: "{value} pesos Mexican coin",
                .french: "Pièce de {value} pesos mexicains",
                .portuguese: "Moeda de {value} pesos mexicanos",
                .german: "{value} Pesos mexikanische Münze",
                .italian: "Moneta da {value} pesos messicani",
                .chinese: "{value}比索墨西哥硬币",
                .japanese: "メキシコ{value}ペソ硬貨"
            ],
            "mexican_bill": [
                .spanish: "Billete de {value} pesos mexicanos",
                .english: "{value} pesos Mexican bill",
                .french: "Billet de {value} pesos mexicains",
                .portuguese: "Nota de {value} pesos mexicanos",
                .german: "{value} Pesos mexikanische Banknote",
                .italian: "Banconota da {value} pesos messicani",
                .chinese: "{value}比索墨西哥纸币",
                .japanese: "メキシコ{value}ペソ紙幣"
            ],
            // MARK: - USA & Canada Currency Lists
            "search_any_currency_usa": [
                .spanish: "Busca cualquier moneda de Estados Unidos en circulación actualmente",
                .english: "Search any currency of the United States currently in circulation",
                .french: "Recherchez n'importe quelle devise des États-Unis actuellement en circulation",
                .portuguese: "Procure qualquer moeda dos Estados Unidos atualmente em circulação",
                .german: "Suchen Sie eine beliebige Währung der Vereinigten Staaten, die derzeit im Umlauf ist",
                .italian: "Cerca qualsiasi valuta degli Stati Uniti attualmente in circolazione",
                .chinese: "搜索美国目前流通的任何货币",
                .japanese: "アメリカで現在流通している通貨を検索"
            ],
            "search_any_currency_canada": [
                .spanish: "Busca cualquier moneda de Canadá en circulación actualmente",
                .english: "Search any currency of Canada currently in circulation",
                .french: "Recherchez n'importe quelle devise du Canada actuellement en circulation",
                .portuguese: "Procure qualquer moeda do Canadá atualmente em circulação",
                .german: "Suchen Sie eine beliebige Währung Kanadas, die derzeit im Umlauf ist",
                .italian: "Cerca qualsiasi valuta del Canada attualmente in circolazione",
                .chinese: "搜索加拿大目前流通的任何货币",
                .japanese: "カナダで現在流通している通貨を検索"
            ],
            "coming_soon": [
                .spanish: "Vista de Detalle - Próximamente",
                .english: "Detail View - Coming Soon",
                .french: "Vue détaillée - Prochainement",
                .portuguese: "Vista de Detalhes - Em Breve",
                .german: "Detailansicht - Demnächst",
                .italian: "Vista Dettagli - Prossimamente",
                .chinese: "详细视图 - 即将推出",
                .japanese: "詳細ビュー - 近日公開"
            ],
            // Monedas USA
            "usa_penny": [
                .spanish: "Moneda de 1 centavo (Penny)",
                .english: "1 cent coin (Penny)",
                .french: "Pièce de 1 cent (Penny)",
                .portuguese: "Moeda de 1 centavo (Penny)",
                .german: "1-Cent-Münze (Penny)",
                .italian: "Moneta da 1 centesimo (Penny)",
                .chinese: "1分硬币 (Penny)",
                .japanese: "1セント硬貨 (Penny)"
            ],
            "usa_nickel": [
                .spanish: "Moneda de 5 centavos (Nickel)",
                .english: "5 cents coin (Nickel)",
                .french: "Pièce de 5 cents (Nickel)",
                .portuguese: "Moeda de 5 centavos (Nickel)",
                .german: "5-Cent-Münze (Nickel)",
                .italian: "Moneta da 5 centesimi (Nickel)",
                .chinese: "5分硬币 (Nickel)",
                .japanese: "5セント硬貨 (Nickel)"
            ],
            "usa_dime": [
                .spanish: "Moneda de 10 centavos (Dime)",
                .english: "10 cents coin (Dime)",
                .french: "Pièce de 10 cents (Dime)",
                .portuguese: "Moeda de 10 centavos (Dime)",
                .german: "10-Cent-Münze (Dime)",
                .italian: "Moneta da 10 centesimi (Dime)",
                .chinese: "10分硬币 (Dime)",
                .japanese: "10セント硬貨 (Dime)"
            ],
            "usa_quarter": [
                .spanish: "Moneda de 25 centavos (Quarter)",
                .english: "25 cents coin (Quarter)",
                .french: "Pièce de 25 cents (Quarter)",
                .portuguese: "Moeda de 25 centavos (Quarter)",
                .german: "25-Cent-Münze (Quarter)",
                .italian: "Moneta da 25 centesimi (Quarter)",
                .chinese: "25分硬币 (Quarter)",
                .japanese: "25セント硬貨 (Quarter)"
            ],
            "usa_half_dollar": [
                .spanish: "Moneda de 50 centavos (Half Dollar)",
                .english: "50 cents coin (Half Dollar)",
                .french: "Pièce de 50 cents (Half Dollar)",
                .portuguese: "Moeda de 50 centavos (Half Dollar)",
                .german: "50-Cent-Münze (Half Dollar)",
                .italian: "Moneta da 50 centesimi (Half Dollar)",
                .chinese: "50分硬币 (Half Dollar)",
                .japanese: "50セント硬貨 (Half Dollar)"
            ],
            "usa_dollar_coin": [
                .spanish: "Moneda de 1 dólar (Dollar Coin)",
                .english: "1 dollar coin (Dollar Coin)",
                .french: "Pièce de 1 dollar (Dollar Coin)",
                .portuguese: "Moeda de 1 dólar (Dollar Coin)",
                .german: "1-Dollar-Münze (Dollar Coin)",
                .italian: "Moneta da 1 dollaro (Dollar Coin)",
                .chinese: "1美元硬币 (Dollar Coin)",
                .japanese: "1ドル硬貨 (Dollar Coin)"
            ],
            "usa_bill_1": [
                .spanish: "Billete de 1 dólar",
                .english: "1 dollar bill",
                .french: "Billet de 1 dollar",
                .portuguese: "Nota de 1 dólar",
                .german: "1-Dollar-Schein",
                .italian: "Banconota da 1 dollaro",
                .chinese: "1美元纸币",
                .japanese: "1ドル紙幣"
            ],
            "usa_bill_2": [
                .spanish: "Billete de 2 dólares",
                .english: "2 dollars bill",
                .french: "Billet de 2 dollars",
                .portuguese: "Nota de 2 dólares",
                .german: "2-Dollar-Schein",
                .italian: "Banconota da 2 dollari",
                .chinese: "2美元纸币",
                .japanese: "2ドル紙幣"
            ],
            "usa_bill_5": [
                .spanish: "Billete de 5 dólares",
                .english: "5 dollars bill",
                .french: "Billet de 5 dollars",
                .portuguese: "Nota de 5 dólares",
                .german: "5-Dollar-Schein",
                .italian: "Banconota da 5 dollari",
                .chinese: "5美元纸币",
                .japanese: "5ドル紙幣"
            ],
            "usa_bill_10": [
                .spanish: "Billete de 10 dólares",
                .english: "10 dollars bill",
                .french: "Billet de 10 dollars",
                .portuguese: "Nota de 10 dólares",
                .german: "10-Dollar-Schein",
                .italian: "Banconota da 10 dollari",
                .chinese: "10美元纸币",
                .japanese: "10ドル紙幣"
            ],
            "usa_bill_20": [
                .spanish: "Billete de 20 dólares",
                .english: "20 dollars bill",
                .french: "Billet de 20 dollars",
                .portuguese: "Nota de 20 dólares",
                .german: "20-Dollar-Schein",
                .italian: "Banconota da 20 dollari",
                .chinese: "20美元纸币",
                .japanese: "20ドル紙幣"
            ],
            "usa_bill_50": [
                .spanish: "Billete de 50 dólares",
                .english: "50 dollars bill",
                .french: "Billet de 50 dollars",
                .portuguese: "Nota de 50 dólares",
                .german: "50-Dollar-Schein",
                .italian: "Banconota da 50 dollari",
                .chinese: "50美元纸币",
                .japanese: "50ドル紙幣"
            ],
            "usa_bill_100": [
                .spanish: "Billete de 100 dólares",
                .english: "100 dollars bill",
                .french: "Billet de 100 dollars",
                .portuguese: "Nota de 100 dólares",
                .german: "100-Dollar-Schein",
                .italian: "Banconota da 100 dollari",
                .chinese: "100美元纸币",
                .japanese: "100ドル紙幣"
            ],
            // Monedas Canadá
            "can_nickel": [
                .spanish: "Moneda de 5 centavos (Nickel)",
                .english: "5 cents coin (Nickel)",
                .french: "Pièce de 5 cents (Nickel)",
                .portuguese: "Moeda de 5 centavos (Nickel)",
                .german: "5-Cent-Münze (Nickel)",
                .italian: "Moneta da 5 centesimi (Nickel)",
                .chinese: "5分硬币 (Nickel)",
                .japanese: "5セント硬貨 (Nickel)"
            ],
            "can_dime": [
                .spanish: "Moneda de 10 centavos (Dime)",
                .english: "10 cents coin (Dime)",
                .french: "Pièce de 10 cents (Dime)",
                .portuguese: "Moeda de 10 centavos (Dime)",
                .german: "10-Cent-Münze (Dime)",
                .italian: "Moneta da 10 centesimi (Dime)",
                .chinese: "10分硬币 (Dime)",
                .japanese: "10セント硬貨 (Dime)"
            ],
            "can_quarter": [
                .spanish: "Moneda de 25 centavos (Quarter)",
                .english: "25 cents coin (Quarter)",
                .french: "Pièce de 25 cents (Quarter)",
                .portuguese: "Moeda de 25 centavos (Quarter)",
                .german: "25-Cent-Münze (Quarter)",
                .italian: "Moneta da 25 centesimi (Quarter)",
                .chinese: "25分硬币 (Quarter)",
                .japanese: "25セント硬貨 (Quarter)"
            ],
            "can_half_dollar": [
                .spanish: "Moneda de 50 centavos (Half Dollar)",
                .english: "50 cents coin (Half Dollar)",
                .french: "Pièce de 50 cents (Half Dollar)",
                .portuguese: "Moeda de 50 centavos (Half Dollar)",
                .german: "50-Cent-Münze (Half Dollar)",
                .italian: "Moneta da 50 centesimi (Half Dollar)",
                .chinese: "50分硬币 (Half Dollar)",
                .japanese: "50セント硬貨 (Half Dollar)"
            ],
            "can_loonie": [
                .spanish: "Moneda de 1 dólar (Loonie)",
                .english: "1 dollar coin (Loonie)",
                .french: "Pièce de 1 dollar (Loonie)",
                .portuguese: "Moeda de 1 dólar (Loonie)",
                .german: "1-Dollar-Münze (Loonie)",
                .italian: "Moneta da 1 dollaro (Loonie)",
                .chinese: "1加元硬币 (Loonie)",
                .japanese: "1ドル硬貨 (Loonie)"
            ],
            "can_toonie": [
                .spanish: "Moneda de 2 dólares (Toonie)",
                .english: "2 dollars coin (Toonie)",
                .french: "Pièce de 2 dollars (Toonie)",
                .portuguese: "Moeda de 2 dólares (Toonie)",
                .german: "2-Dollar-Münze (Toonie)",
                .italian: "Moneta da 2 dollari (Toonie)",
                .chinese: "2加元硬币 (Toonie)",
                .japanese: "2ドル硬貨 (Toonie)"
            ],
            "can_bill_5": [
                .spanish: "Billete de 5 dólares",
                .english: "5 dollars bill",
                .french: "Billet de 5 dollars",
                .portuguese: "Nota de 5 dólares",
                .german: "5-Dollar-Schein",
                .italian: "Banconota da 5 dollari",
                .chinese: "5加元纸币",
                .japanese: "5ドル紙幣"
            ],
            "can_bill_10": [
                .spanish: "Billete de 10 dólares",
                .english: "10 dollars bill",
                .french: "Billet de 10 dollars",
                .portuguese: "Nota de 10 dólares",
                .german: "10-Dollar-Schein",
                .italian: "Banconota da 10 dollari",
                .chinese: "10加元纸币",
                .japanese: "10ドル紙幣"
            ],
            "can_bill_20": [
                .spanish: "Billete de 20 dólares",
                .english: "20 dollars bill",
                .french: "Billet de 20 dollars",
                .portuguese: "Nota de 20 dólares",
                .german: "20-Dollar-Schein",
                .italian: "Banconota da 20 dollari",
                .chinese: "20加元纸币",
                .japanese: "20ドル紙幣"
            ],
            "can_bill_50": [
                .spanish: "Billete de 50 dólares",
                .english: "50 dollars bill",
                .french: "Billet de 50 dollars",
                .portuguese: "Nota de 50 dólares",
                .german: "50-Dollar-Schein",
                .italian: "Banconota da 50 dollari",
                .chinese: "50加元纸币",
                .japanese: "50ドル紙幣"
            ],
            "can_bill_100": [
                .spanish: "Billete de 100 dólares",
                .english: "100 dollars bill",
                .french: "Billet de 100 dollars",
                .portuguese: "Nota de 100 dólares",
                .german: "100-Dollar-Schein",
                .italian: "Banconota da 100 dollari",
                .chinese: "100加元纸币",
                .japanese: "100ドル紙幣"
            ],
            // MARK: - IdentificadorView - Denominaciones
            "bill_20": [
                .spanish: "💵 Billete de $20 pesos",
                .english: "💵 $20 pesos bill",
                .french: "💵 Billet de 20 pesos",
                .portuguese: "💵 Nota de 20 pesos",
                .german: "💵 20-Pesos-Schein",
                .italian: "💵 Banconota da 20 pesos",
                .chinese: "💵 20比索纸币",
                .japanese: "💵 20ペソ紙幣"
            ],
            "bill_50": [
                .spanish: "💵 Billete de $50 pesos",
                .english: "💵 $50 pesos bill",
                .french: "💵 Billet de 50 pesos",
                .portuguese: "💵 Nota de 50 pesos",
                .german: "💵 50-Pesos-Schein",
                .italian: "💵 Banconota da 50 pesos",
                .chinese: "💵 50比索纸币",
                .japanese: "💵 50ペソ紙幣"
            ],
            "bill_100": [
                .spanish: "💵 Billete de $100 pesos",
                .english: "💵 $100 pesos bill",
                .french: "💵 Billet de 100 pesos",
                .portuguese: "💵 Nota de 100 pesos",
                .german: "💵 100-Pesos-Schein",
                .italian: "💵 Banconota da 100 pesos",
                .chinese: "💵 100比索纸币",
                .japanese: "💵 100ペソ紙幣"
            ],
            "bill_200": [
                .spanish: "💵 Billete de $200 pesos",
                .english: "💵 $200 pesos bill",
                .french: "💵 Billet de 200 pesos",
                .portuguese: "💵 Nota de 200 pesos",
                .german: "💵 200-Pesos-Schein",
                .italian: "💵 Banconota da 200 pesos",
                .chinese: "💵 200比索纸币",
                .japanese: "💵 200ペソ紙幣"
            ],
            "bill_500": [
                .spanish: "💵 Billete de $500 pesos",
                .english: "💵 $500 pesos bill",
                .french: "💵 Billet de 500 pesos",
                .portuguese: "💵 Nota de 500 pesos",
                .german: "💵 500-Pesos-Schein",
                .italian: "💵 Banconota da 500 pesos",
                .chinese: "💵 500比索纸币",
                .japanese: "💵 500ペソ紙幣"
            ],
            "bill_1000": [
                .spanish: "💵 Billete de $1,000 pesos",
                .english: "💵 $1,000 pesos bill",
                .french: "💵 Billet de 1 000 pesos",
                .portuguese: "💵 Nota de 1.000 pesos",
                .german: "💵 1.000-Pesos-Schein",
                .italian: "💵 Banconota da 1.000 pesos",
                .chinese: "💵 1,000比索纸币",
                .japanese: "💵 1,000ペソ紙幣"
            ],
            "coin_10c": [
                .spanish: "🪙 Moneda de 10 centavos",
                .english: "🪙 10 cents coin",
                .french: "🪙 Pièce de 10 centimes",
                .portuguese: "🪙 Moeda de 10 centavos",
                .german: "🪙 10-Centavos-Münze",
                .italian: "🪙 Moneta da 10 centesimi",
                .chinese: "🪙 10分硬币",
                .japanese: "🪙 10センタボス硬貨"
            ],
            "coin_50c": [
                .spanish: "🪙 Moneda de 50 centavos",
                .english: "🪙 50 cents coin",
                .french: "🪙 Pièce de 50 centimes",
                .portuguese: "🪙 Moeda de 50 centavos",
                .german: "🪙 50-Centavos-Münze",
                .italian: "🪙 Moneta da 50 centesimi",
                .chinese: "🪙 50分硬币",
                .japanese: "🪙 50センタボス硬貨"
            ],
            "coin_1p": [
                .spanish: "🪙 Moneda de $1 peso",
                .english: "🪙 $1 peso coin",
                .french: "🪙 Pièce de 1 peso",
                .portuguese: "🪙 Moeda de 1 peso",
                .german: "🪙 1-Peso-Münze",
                .italian: "🪙 Moneta da 1 peso",
                .chinese: "🪙 1比索硬币",
                .japanese: "🪙 1ペソ硬貨"
            ],
            "coin_2p": [
                .spanish: "🪙 Moneda de $2 pesos",
                .english: "🪙 $2 pesos coin",
                .french: "🪙 Pièce de 2 pesos",
                .portuguese: "🪙 Moeda de 2 pesos",
                .german: "🪙 2-Pesos-Münze",
                .italian: "🪙 Moneta da 2 pesos",
                .chinese: "🪙 2比索硬币",
                .japanese: "🪙 2ペソ硬貨"
            ],
            "coin_5p": [
                .spanish: "🪙 Moneda de $5 pesos",
                .english: "🪙 $5 pesos coin",
                .french: "🪙 Pièce de 5 pesos",
                .portuguese: "🪙 Moeda de 5 pesos",
                .german: "🪙 5-Pesos-Münze",
                .italian: "🪙 Moneta da 5 pesos",
                .chinese: "🪙 5比索硬币",
                .japanese: "🪙 5ペソ硬貨"
            ],
            "coin_10p": [
                .spanish: "🪙 Moneda de $10 pesos",
                .english: "🪙 $10 pesos coin",
                .french: "🪙 Pièce de 10 pesos",
                .portuguese: "🪙 Moeda de 10 pesos",
                .german: "🪙 10-Pesos-Münze",
                .italian: "🪙 Moneta da 10 pesos",
                .chinese: "🪙 10比索硬币",
                .japanese: "🪙 10ペソ硬貨"
            ],
            "coin_20p": [
                .spanish: "🪙 Moneda de $20 pesos",
                .english: "🪙 $20 pesos coin",
                .french: "🪙 Pièce de 20 pesos",
                .portuguese: "🪙 Moeda de 20 pesos",
                .german: "🪙 20-Pesos-Münze",
                .italian: "🪙 Moneta da 20 pesos",
                .chinese: "🪙 20比索硬币",
                .japanese: "🪙 20ペソ硬貨"
            ],
            "detecting_model": [
                .spanish: "Detectando: {model}",
                .english: "Detecting: {model}",
                .french: "Détection: {model}",
                .portuguese: "Detectando: {model}",
                .german: "Erkennung: {model}",
                .italian: "Rilevamento: {model}",
                .chinese: "检测中：{model}",
                .japanese: "検出中：{model}"
            ],
            "analyzing_type": [
                .spanish: "Analizando {type}...",
                .english: "Analyzing {type}...",
                .french: "Analyse de {type}...",
                .portuguese: "Analisando {type}...",
                .german: "Analysiere {type}...",
                .italian: "Analizzando {type}...",
                .chinese: "分析{type}中...",
                .japanese: "{type}を分析中..."
            ],
            "processing_error": [
                .spanish: "❌ Error al procesar la imagen",
                .english: "❌ Error processing image",
                .french: "❌ Erreur de traitement de l'image",
                .portuguese: "❌ Erro ao processar imagem",
                .german: "❌ Fehler beim Verarbeiten des Bildes",
                .italian: "❌ Errore nell'elaborazione dell'immagine",
                .chinese: "❌ 处理图像时出错",
                .japanese: "❌ 画像処理エラー"
            ],
            "low_confidence_message": [
                .spanish: "No se pudo identificar con suficiente confianza",
                .english: "Could not identify with sufficient confidence",
                .french: "Impossible d'identifier avec suffisamment de confiance",
                .portuguese: "Não foi possível identificar com confiança suficiente",
                .german: "Konnte nicht mit ausreichender Sicherheit identifiziert werden",
                .italian: "Impossibile identificare con sufficiente confidenza",
                .chinese: "无法以足够的置信度识别",
                .japanese: "十分な信頼度で識別できませんでした"
            ],
            "coin_cent_singular": [
                .spanish: "Moneda de {value} centavo mexicano",
                .english: "{value} cent Mexican coin",
                .french: "Pièce de {value} centime mexicain",
                .portuguese: "Moeda de {value} centavo mexicano",
                .german: "{value} Centavo mexikanische Münze",
                .italian: "Moneta da {value} centesimo messicano",
                .chinese: "{value}分墨西哥硬币",
                .japanese: "メキシコ{value}センタボス硬貨"
            ],
        ]
        
        return translations[key]?[language] ?? key
    }
    
    // Helper para traducciones universales (mismo texto en todos los idiomas)
    private static func universalTranslation(_ text: String) -> [AppLanguage: String] {
        return Dictionary(uniqueKeysWithValues: AppLanguage.allCases.map { ($0, text) })
    }
}

// MARK: - Extension para usar en Views
extension String {
    func localized() -> String {
        return LocalizationManager3.shared.localizedString(self)
    }
}
