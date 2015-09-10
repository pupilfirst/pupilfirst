# Configuration keys in Use (clean this up frequently).
#
# sms_statistics_all: SMS Statistics All
# sms_statistics_total: SMS Statistics Total
# sms_statistics_visakhapatnam: SMS Statistics Visakhapatnam
# sms_statistics_kochi: SMS Statistics Kochi
# feature_faculty_page: Toggle Faculty Page
# feature_about_page: (dev) Toggle About Page
# feature_startups: (dev) Toggle Startups
#
class Feature < ActiveRecord::Base
  # {"email_regexes": ["\S*(@mobme.in|sv.co)$"], "emails": ["someone@sv.co"]}
  #     OR
  # {"active": true}
  def self.feature_active?(key, user=nil)
    feature = where(key: "feature_#{key}").first

    return false unless feature

    feature_value = begin
      JSON.load(feature.value).with_indifferent_access
    rescue JSON::ParserError
      return false
    end

    return true if feature_value[:active].present?

    if user
      if feature_value.include? :email_regexes
        feature_value[:email_regexes].each do |email_regex|
          return true if Regexp.new(email_regex).match(user.email)
        end
      end

      if feature_value.include? :emails
        return true if feature_value[:emails].include? user.email
      end
    end

    false
  end
end
