# The following monkey-patch fixes https://github.com/fnando/i18n-js/issues/616
module I18nJS
  def self.translations
    ::I18n.backend.send(:init_translations)
    ::I18n.backend.send(:translations)
  end
end

I18n.available_locales = ENV.fetch('I18N_AVAILABLE_LOCALES', 'en,ru,ar,zh-cn').split(',')
I18n.default_locale = ENV.fetch('I18N_DEFAULT_LOCALE', 'en')
