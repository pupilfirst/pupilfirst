module Founders
  class EditForm < Reform::Form
    include CollegeAddable

    property :name
    property :born_on, validates: { presence: true }
    property :phone, validates: { presence: true, mobile_number: true }
    property :avatar
    property :about, validates: { length: { maximum: 250 } }
    property :roles, validates: { presence: true, inclusion: { in: Founder.valid_roles } }
    property :slack_username
    property :skype_id
    property :communication_address, validates: { length: { maximum: 250 } }
    property :identification_proof
    property :college_id, validates: { presence: true }
    property :twitter_url, validates: { url: true, allow_nil: true }
    property :linkedin_url, validates: { url: true, allow_nil: true }
    property :personal_website_url, validates: { url: true, allow_nil: true }
    property :blog_url, validates: { url: true, allow_nil: true }
    property :angel_co_url, validates: { url: true, allow_nil: true }
    property :github_url, validates: { url: true, allow_nil: true }
    property :behance_url, validates: { url: true, allow_nil: true }

    # Custom validations.
    validate :slack_username_format
    validate :slack_username_must_exist

    delegate :avatar?, to: :model

    def slack_username_format
      return if slack_username.blank?
      username_match = slack_username.match(/^@?([a-z\d\.\_\-]{,21})$/)
      return if username_match.present?
      errors.add(:slack_username, 'is not valid. Should only contain lower-case letters, numbers, periods, hyphen and underscores.')
    end

    def slack_username_must_exist
      return if slack_username.blank?
      return unless slack_username_changed?
      return if Rails.env.development?

      response_json = JSON.parse(RestClient.get("https://slack.com/api/users.list?token=#{Rails.application.secrets.slack_token}"))

      unless response_json['ok']
        errors.add(:slack_username, 'unable to validate username from slack. Please try again')
        return
      end

      valid_names = response_json['members'].map { |m| m['name'] }
      index = valid_names.index slack_username

      if index.present?
        @new_slack_user_id = response_json['members'][index]['id']
      else
        errors.add(:slack_username, 'a user with this mention name does not exist on SV.CO Public Slack')
      end
    end
  end
end
