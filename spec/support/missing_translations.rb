require 'rspec/expectations'

RSpec::Matchers.define :have_missing_translations do

  match do |actual|
    # Default missing translation fallback for i18n-js
    missing_i18n_js = /\[missing "\S*" translation\]/

    # Default missing translation fallback for the Rails t() helper
    missing_rails_t = /class="translation_missing"/

    # Default missing translation fallback for I18n.t
    missing_i18n_t  = /translation missing: \S*\.\S*/

    !!(actual.body.match(missing_rails_t) ||
       actual.body.match(missing_i18n_t)  ||
       actual.body.match(missing_i18n_js))
  end

  failure_message do
    'expected page to have missing translations'
  end

  failure_message_when_negated do
    'expected page to not have missing translations'
  end
end