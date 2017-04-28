# Feature flags! Set any key and check for it with Feature.active?(key, [current_founder])
# See documentation of method to see how to store the JSON value.
class Feature < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true

  validate :value_must_be_json

  def value_must_be_json
    JSON.parse value
  rescue JSON::ParserError
    errors[:value] << 'must be valid JSON'
  end

  class << self
    attr_writer :skip_override

    # {"email_regexes": ["\S*(@mobme.in|sv.co)$"], "emails": ["someone@sv.co"]}
    #     OR
    # {"active": true}
    def active?(key, founder = nil)
      return true if overridden?

      feature = find_by(key: key)

      return false unless feature

      parsed_value = begin
        JSON.parse(feature.value).with_indifferent_access
      rescue JSON::ParserError
        return false
      end

      return true if parsed_value[:active].present?
      return true if feature.active_for_founder?(founder, parsed_value)

      false
    end

    def overridden?
      return false if @skip_override
      Rails.env.development? || Rails.env.test?
    end
  end

  def active_for_founder?(founder, parsed_value)
    return false unless founder

    if parsed_value.include? :email_regexes
      parsed_value[:email_regexes].each do |email_regex|
        return true if Regexp.new(email_regex).match(founder.email)
      end
    end

    true if parsed_value.include?(:emails) && parsed_value[:emails].include?(founder.email)
  end
end
