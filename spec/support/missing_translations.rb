require 'rspec/expectations'

I18N_CHARS = '([a-zA-Z0-9_\.]+)'

# Default missing translation fallback for i18n-js
MISSING_I18N_JS = /\[missing "#{I18N_CHARS}" translation\]/

# Default missing translation fallback for the Rails t() helper
MISSING_RAILS_T = /class="translation_missing"/

# Default missing translation fallback for I18n.t
MISSING_I18N_T = /translation missing: #{I18N_CHARS}/

RSpec::Matchers.define :have_missing_translations do
  match do |actual|
    actual.body.match?(MISSING_RAILS_T) || actual.body.match?(MISSING_I18N_T) ||
      actual.body.match?(MISSING_I18N_JS)
  end

  failure_message { 'expected page to have missing translations' }

  failure_message_when_negated do |actual|
    missing_translations =
      actual.body.scan(MISSING_I18N_T) + actual.body.scan(MISSING_I18N_JS)

    if missing_translations.any?
      "expected page to not have missing translations: #{missing_translations.join(', ')}"
    else
      'expected page to not have missing translations'
    end
  end
end
