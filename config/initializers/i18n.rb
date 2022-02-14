# The following monkey-patch fixes https://github.com/fnando/i18n-js/issues/616
module I18nJS
  def self.translations
    ::I18n.backend.send(:init_translations)
    ::I18n.backend.send(:translations)
  end
end

I18n.available_locales = Rails.application.secrets.locale[:available]
I18n.default_locale = Rails.application.secrets.locale[:default]
