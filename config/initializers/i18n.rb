I18n.available_locales = Settings.locale[:available]
I18n.default_locale = Settings.locale[:default]

if Settings.locale[:default] != "en"
  Rails.application.config.i18n.fallbacks = [
    Settings.locale[:default].to_sym,
    :en
  ]
end
