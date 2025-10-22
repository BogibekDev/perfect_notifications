import Flutter

/// Flutter Result'ga javob qaytarish helper'i
class ResultHandler {

    /// Success natija qaytarish
    /// - Parameters:
    ///   - result: FlutterResult
    ///   - data: Qaytariladigan data (optional)
    func success(_ result: FlutterResult, data: Any? = nil) {
        result(data)
    }

    /// Error qaytarish
    /// - Parameters:
    ///   - result: FlutterResult
    ///   - code: Error kodi
    ///   - message: Error xabari
    ///   - details: Qo'shimcha ma'lumot
    func error(
        _ result: FlutterResult,
        code: String,
        message: String,
        details: Any? = nil
    ) {
        result(FlutterError(code: code, message: message, details: details))
    }

    /// Method implement qilinmagan
    func notImplemented(_ result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    /// ArgumentParser.ParseResult'dan avtomatik javob
    /// - Parameters:
    ///   - result: FlutterResult
    ///   - parseResult: ArgumentParser'dan kelgan natija
    ///   - onSuccess: Success bo'lganda chaqiriladigan closure
    func handleParseResult<T>(
        _ result: FlutterResult,
        parseResult: ArgumentParser.ParseResult<T>,
        onSuccess: (T) -> Void
    ) {
        switch parseResult {
        case .success(let data):
            onSuccess(data)
        case .error(let code, let message, let details):
            error(result, code: code, message: message, details: details)
        }
    }
}