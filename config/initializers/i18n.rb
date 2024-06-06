I18n.available_locales = Rails.application.secrets.locale[:available]
I18n.default_locale = Rails.application.secrets.locale[:default]

if Rails.application.secrets.locale[:default] != "en"
  Rails.application.config.i18n.fallbacks = [
    Rails.application.secrets.locale[:default].to_sym,
    :en
  ]
end
