package org.perfect.notifications.perfect_notifications.utils

import io.flutter.plugin.common.MethodCall


/**
 * Method call argumentlarini parse qilish va validate qilish
 * Single Responsibility: Faqat parsing
 */
class ArgumentParser {

    /**
     * Map argumentlarini parse qiladi va validate qiladi
     */
    fun <T> parse(
        call: MethodCall,
        parser: (Map<String, Any?>) -> T
    ): ParseResult<T> {
        val args = call.arguments

        if (args !is Map<*, *>) {
            return ParseResult.Error(
                code = "INVALID_ARGUMENTS",
                message = "Expected Map<String, Any?> but got $args"
            )
        }

        return try {
            @Suppress("UNCHECKED_CAST")
            val map = args as Map<String, Any?>
            val data = parser(map)
            ParseResult.Success(data)
        } catch (e: Exception) {
            ParseResult.Error(
                code = "PARSE_ERROR",
                message = e.message ?: "Unknown parsing error",
                details = e.toString()
            )
        }
    }

    sealed class ParseResult<out T> {
        data class Success<T>(val data: T) : ParseResult<T>()
        data class Error(
            val code: String,
            val message: String,
            val details: String? = null
        ) : ParseResult<Nothing>()
    }
}