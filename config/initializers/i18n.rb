# All locales should be listed here, even if they are in `I18N_AVAILABLE_LOCALES`.
I18n.available_locales = %w[en ru ar zh-cn pt-br]

I18n.default_locale = Rails.application.secrets.locale[:default]

if Rails.application.secrets.locale[:default] != "en"
  Rails.application.config.i18n.fallbacks = [
    Rails.application.secrets.locale[:default].to_sym,
    :en
  ]
end
