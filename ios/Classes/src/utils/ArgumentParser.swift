import Foundation

/// Method call argumentlarini parse qilish va validate qilish
class ArgumentParser {

    /// Parse natijasi - Success yoki Error
    enum ParseResult<T> {
        case success(T)
        case error(code: String, message: String, details: String? = nil)
    }

    /// Map argumentlarini parse qiladi
    /// - Parameters:
    ///   - arguments: MethodCall'dan kelgan arguments
    ///   - parser: Map'ni model'ga o'tkazuvchi closure
    /// - Returns: ParseResult<T>
    func parse<T>(
        arguments: Any?,
        parser: ([String: Any]) throws -> T
    ) -> ParseResult<T> {
        // Argumentlar Map ekanligini tekshirish
        guard let map = arguments as? [String: Any] else {
            return .error(
                code: "INVALID_ARGUMENTS",
                message: "Expected [String: Any] but got \(type(of: arguments))"
            )
        }

        // Parse qilish
        do {
            let data = try parser(map)
            return .success(data)
        } catch let decodingError as DecodingError {
            // JSON decode error
            return .error(
                code: "PARSE_ERROR",
                message: "Failed to decode: \(decodingError.localizedDescription)",
                details: "\(decodingError)"
            )
        } catch {
            // Boshqa error'lar
            return .error(
                code: "PARSE_ERROR",
                message: error.localizedDescription,
                details: "\(error)"
            )
        }
    }

    /// String argumentni olish (simple case)
    /// - Parameters:
    ///   - arguments: MethodCall arguments
    ///   - key: Key nomi
    /// - Returns: String yoki nil
    func getString(arguments: Any?, key: String) -> String? {
        guard let map = arguments as? [String: Any] else { return nil }
        return map[key] as? String
    }

    /// Int argumentni olish
    func getInt(arguments: Any?, key: String) -> Int? {
        guard let map = arguments as? [String: Any] else { return nil }
        return map[key] as? Int
    }

    /// Bool argumentni olish
    func getBool(arguments: Any?, key: String) -> Bool? {
        guard let map = arguments as? [String: Any] else { return nil }
        return map[key] as? Bool
    }
}