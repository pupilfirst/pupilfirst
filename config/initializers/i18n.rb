module I18nJS
  def self.translations
    ::I18n.backend.send(:init_translations)
    ::I18n.backend.send(:translations)
  end
end

I18n.available_locales = %w[en]
I18n.default_locale = 'en'
I18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml').to_s]

require 'i18n-js/listen'

I18nJS.listen
