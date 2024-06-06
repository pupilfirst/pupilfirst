I18n.available_locales = ENV.fetch('I18N_AVAILABLE_LOCALES', 'en,ru,ar,zh-cn').split(',')
I18n.default_locale = ENV.fetch('I18N_DEFAULT_LOCALE', 'en')

if Rails.application.secrets.locale[:default] != "en"
  Rails.application.config.i18n.fallbacks = [
    Rails.application.secrets.locale[:default].to_sym,
    :en
  ]
end
