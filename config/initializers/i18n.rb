# All locales should be listed here, even if they are in `I18N_AVAILABLE_LOCALES`.
I18n.available_locales = %w[en ru ar zh-cn pt-br]

I18n.default_locale = Settings.locale.default

if Settings.locale.default != "en"
  Rails.application.config.i18n.fallbacks = [
    Settings.locale.default.to_sym,
    :en
  ]
end
