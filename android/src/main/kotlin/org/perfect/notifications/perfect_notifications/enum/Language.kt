package org.perfect.notifications.perfect_notifications.enum

enum class LanguageEnum(val locale: String) {
    UzbekLatin("uz"),
    UzbekCyrillic("uz-Cyrl"),
    Russian("ru"),
    Kazakh("kk"),
    Kyrgyz("ky"),
    Tajik("tg"),
    Turkmen("tk"),
    Azerbaijani("az"),
    Armenian("hy"),
    Georgian("ka"),
    Ukrainian("uk"),
    English("en"),
    OzbekCyrillic("oz");

    companion object {
        fun fromLocale(locale: String): LanguageEnum {
            return entries.firstOrNull { it.locale.equals(locale, ignoreCase = true) } ?: UzbekLatin
        }
    }
}
