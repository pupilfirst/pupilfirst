# Feature flags! Set any key and check for it with Feature.active?(key, current_user)
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

    # {"admin": true}
    #
    # {"email_regexes": ["\\S+@example.com$"], "emails": ["someone@example.com"]}
    #     OR
    # {"active": true}
    def active?(key, user = nil)
      return true if overridden?

      feature = find_by(key: key)

      return false unless feature

      parsed_value = JSON.parse(feature.value).with_indifferent_access

      return true if parsed_value[:active].present?

      feature.active_for_user?(user, parsed_value)
    rescue JSON::ParserError
      false
    end

    def overridden?
      return false if @skip_override

      Rails.env.development? || Rails.env.test?
    end
  end

  def active_for_user?(user, parsed_value)
    return false unless user
    return true if active_for_admin?(user, parsed_value)
    return true if active_for_regex?(user, parsed_value)
    return true if active_for_email?(user, parsed_value)

    false
  end

  def active_for_admin?(user, parsed_value)
    return false unless parsed_value.include?(:admin)

    AdminUser.exists?(email: user.email)
  end

  def active_for_regex?(user, parsed_value)
    return false unless parsed_value.include? :email_regexes

    parsed_value[:email_regexes].each do |email_regex|
      return true if Regexp.new(email_regex).match?(user.email)
    end

    false
  end

  def active_for_email?(user, parsed_value)
    return false unless parsed_value.include?(:emails)

    parsed_value[:emails].include?(user.email)
  end
end
