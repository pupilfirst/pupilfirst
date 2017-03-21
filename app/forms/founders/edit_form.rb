module Founders
  class EditForm < Reform::Form
    property :name, validates: { presence: true }
    property :born_on, validates: { presence: true }
    property :phone, validates: { presence: true, mobile_number: true }
    property :avatar, validates: { file_size: { less_than: 2.megabytes }, file_content_type: { allow: %w(image/jpeg image/png image/gif) } }
    property :about, validates: { length: { maximum: 250 } }
    property :roles
    property :slack_username
    property :skype_id
    property :communication_address, validates: { presence: true, length: { maximum: 250 } }
    property :identification_proof
    property :college_id, validates: { presence: true }
    property :roll_number
    property :college_identification, validates: { file_size: { less_than: 2.megabytes }, file_content_type: { allow: %w(image/jpeg image/png image/gif) } }
    property :course
    property :semester, validates: { inclusion: MoocStudent.valid_semester_values, allow_blank: true }
    property :year_of_graduation, validates: { inclusion: (1990..2020), allow_blank: true }
    property :backlog
    property :twitter_url, validates: { url: true, allow_blank: true }
    property :linkedin_url, validates: { url: true, allow_blank: true }
    property :personal_website_url, validates: { url: true, allow_blank: true }
    property :blog_url, validates: { url: true, allow_blank: true }
    property :angel_co_url, validates: { url: true, allow_blank: true }
    property :github_url, validates: { url: true, allow_blank: true }
    property :behance_url, validates: { url: true, allow_blank: true }

    # Custom validations.
    validate :slack_username_format
    validate :slack_username_must_exist
    validate :college_must_exist
    validate :roles_must_be_valid

    delegate :avatar?, :college_identification?, to: :model

    def roles_must_be_valid
      roles.each do |role|
        unless Founder.valid_roles.include?(role)
          errors.add(:roles, 'contained unrecognized value')
        end
      end
    end

    def slack_username_format
      return if slack_username.blank?
      username_match = slack_username.match(/^@?([a-z\d\.\_\-]{,21})$/)
      return if username_match.present?
      errors.add(:slack_username, 'is not valid. Should only contain lower-case letters, numbers, periods, hyphen and underscores.')
    end

    def slack_username_must_exist
      return if slack_username.blank?
      return unless slack_username != model.slack_username
      return if Rails.env.development?

      begin
        model.slack_user_id = Slack::FindUserService.new(slack_username).id
      rescue Slack::UserNotFoundException
        errors.add(:slack_username, 'username is not registered on SV.CO Public Slack')
      rescue Slack::ApiFailedException
        errors.add(:slack_username, 'unable to validate username from Slack. Please try again')
      end
    end

    def college_must_exist
      return if college_id.blank?
      return if college_id == 'other'
      return if College.find(college_id).present?

      errors[:college_id] << 'is invalid'
    end

    # Manually coerce year_of_graduation to number.
    def year_of_graduation=(value)
      super(value.present? ? value.to_i : nil)
    end

    def save!
      sync
      model.college_id = nil if college_id == 'other'
      model.save!
    end
  end
end
