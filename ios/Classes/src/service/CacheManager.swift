import Foundation

/// Settings va config'larni saqlash
class CacheManager {

    // MARK: - Keys

    private enum Keys {
        static let locale = "perfect_notifications_locale"
        static let channels = "perfect_notifications_channels"
        static let defaultChannelId = "perfect_notifications_default_channel"
    }

    // MARK: - UserDefaults

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .perfectNotifications) {
        self.defaults = defaults
    }

    // MARK: - Locale (Language)

    /// Language saqlash
    /// - Parameter locale: Language locale (uz, ru, en, ...)
    func saveLocale(_ locale: String) {
        defaults.set(locale, forKey: Keys.locale)
        defaults.synchronize()
        print("💾 Locale saved: \(locale)")
    }

    /// Language olish
    /// - Returns: Saqlangan locale yoki default (uz)
    func getLocale() -> String {
        return defaults.string(forKey: Keys.locale) ?? "uz"
    }

    // MARK: - Channels (iOS'da ishlatilmaydi, lekin compatibility uchun)

    /// Channel'larni saqlash
    /// - Parameters:
    ///   - channels: Channel'lar ro'yxati
    ///   - defaultId: Default channel ID
    func saveChannels(_ channels: [ChannelDetails], defaultId: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(channels)
            defaults.set(data, forKey: Keys.channels)
            defaults.set(defaultId, forKey: Keys.defaultChannelId)
            defaults.synchronize()
            print("💾 Channels saved: \(channels.count) items")
        } catch {
            print("❌ Failed to save channels: \(error.localizedDescription)")
        }
    }

    /// Channel'larni o'qish
    /// - Returns: Saqlangan channel'lar
    func readChannels() -> [ChannelDetails] {
        guard let data = defaults.data(forKey: Keys.channels) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            let channels = try decoder.decode([ChannelDetails].self, from: data)
            return channels
        } catch {
            print("❌ Failed to read channels: \(error.localizedDescription)")
            return []
        }
    }

    /// Bitta channel topish
    /// - Parameter id: Channel ID
    /// - Returns: Channel yoki nil
    func findChannel(id: String) -> ChannelDetails? {
        return readChannels().first { $0.id == id }
    }

    /// Default channel ID
    func getDefaultChannelId() -> String {
        return defaults.string(forKey: Keys.defaultChannelId) ?? "default_channel"
    }

    // MARK: - Generic Storage

    /// String saqlash
    func set(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    /// String o'qish
    func string(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }

    /// Int saqlash
    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    /// Int o'qish
    func integer(forKey key: String) -> Int {
        return defaults.integer(forKey: key)
    }

    /// Bool saqlash
    func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    /// Bool o'qish
    func bool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }

    /// Dictionary saqlash
    func set(_ value: [String: Any], forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    /// Dictionary o'qish
    func dictionary(forKey key: String) -> [String: Any]? {
        return defaults.dictionary(forKey: key)
    }

    /// Value o'chirish
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }

    /// Barcha data'ni tozalash
    func clearAll() {
        if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
            defaults.synchronize()
            print("🗑️ Cache cleared")
        }
    }
}

// MARK: - Language Enum (Android bilan mos)

enum LanguageEnum: String {
    case uzbekLatin = "uz"
    case uzbekCyrillic = "uz-Cyrl"
    case russian = "ru"
    case kazakh = "kk"
    case kyrgyz = "ky"
    case tajik = "tg"
    case turkmen = "tk"
    case azerbaijani = "az"
    case armenian = "hy"
    case georgian = "ka"
    case ukrainian = "uk"
    case english = "en"

    /// Locale'dan enum yaratish
    static func from(locale: String) -> LanguageEnum {
        return LanguageEnum(rawValue: locale) ?? .uzbekLatin
    }

    /// User-friendly nom
    var displayName: String {
        switch self {
        case .uzbekLatin: return "O'zbek (Lotin)"
        case .uzbekCyrillic: return "Ўзбек (Кирилл)"
        case .russian: return "Русский"
        case .kazakh: return "Қазақ"
        case .kyrgyz: return "Кыргыз"
        case .tajik: return "Тоҷикӣ"
        case .turkmen: return "Türkmen"
        case .azerbaijani: return "Azərbaycan"
        case .armenian: return "Հայերեն"
        case .georgian: return "ქართული"
        case .ukrainian: return "Українська"
        case .english: return "English"
        }
    }
}