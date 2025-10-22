import Flutter
import Foundation

/// Language (locale) management
class LanguageHandler {

    // MARK: - Properties

    private let cacheManager: CacheManager
    private let argumentParser: ArgumentParser
    private let resultHandler: ResultHandler

    // MARK: - Initialization

    init(
        cacheManager: CacheManager,
        argumentParser: ArgumentParser = ArgumentParser(),
        resultHandler: ResultHandler = ResultHandler()
    ) {
        self.cacheManager = cacheManager
        self.argumentParser = argumentParser
        self.resultHandler = resultHandler
    }

    // MARK: - Save Language

    /// Language saqlash
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleSaveLanguage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let locale = argumentParser.getString(arguments: call.arguments, key: "locale") else {
            resultHandler.error(
                result,
                code: "INVALID_ARGUMENTS",
                message: "locale is required",
                details: nil
            )
            return
        }

        // Validate locale
        let language = LanguageEnum.from(locale: locale)

        // Save
        cacheManager.saveLocale(language.rawValue)

        print("🌐 Language saved: \(language.displayName) (\(language.rawValue))")
        resultHandler.success(result, data: true)
    }

    // MARK: - Get Language

    /// Language olish
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleGetLanguage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let locale = cacheManager.getLocale()
        let language = LanguageEnum.from(locale: locale)

        resultHandler.success(result, data: [
            "locale": language.rawValue,
            "displayName": language.displayName
        ])
    }

    // MARK: - Get Supported Languages

    /// Qo'llab-quvvatlanadigan language'lar ro'yxati
    /// - Parameters:
    ///   - call: MethodCall
    ///   - result: FlutterResult
    func handleGetSupportedLanguages(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let languages = [
            LanguageEnum.uzbekLatin,
            LanguageEnum.uzbekCyrillic,
            LanguageEnum.russian,
            LanguageEnum.kazakh,
            LanguageEnum.kyrgyz,
            LanguageEnum.tajik,
            LanguageEnum.turkmen,
            LanguageEnum.azerbaijani,
            LanguageEnum.armenian,
            LanguageEnum.georgian,
            LanguageEnum.ukrainian,
            LanguageEnum.english
        ]

        let languageList = languages.map { language in
            return [
                "locale": language.rawValue,
                "displayName": language.displayName
            ]
        }

        resultHandler.success(result, data: languageList)
    }
}