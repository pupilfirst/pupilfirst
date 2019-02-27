module Founders
  class EditForm < Reform::Form
    property :name, validates: { presence: true }
    property :phone, validates: { presence: true, mobile_number: true }
    property :avatar
    property :about, validates: { length: { maximum: 250 } }
    property :roles
    property :skype_id
    property :communication_address, validates: { presence: true, length: { maximum: 250 } }
    property :college_id, validates: { presence: true }
    property :twitter_url, validates: { url: true, allow_blank: true }
    property :linkedin_url, validates: { url: true, allow_blank: true }
    property :personal_website_url, validates: { url: true, allow_blank: true }
    property :blog_url, validates: { url: true, allow_blank: true }
    property :angel_co_url, validates: { url: true, allow_blank: true }
    property :github_url, validates: { url: true, allow_blank: true }
    property :behance_url, validates: { url: true, allow_blank: true }

    # Custom validations.
    validate :college_must_exist
    validate :roles_must_be_valid

    def roles_must_be_valid
      roles.each do |role|
        next if role.blank?

        unless Founder.valid_roles.include?(role)
          errors.add(:roles, 'contained unrecognized value')
        end
      end
    end

    def college_must_exist
      return if college_id.blank?
      return if college_id == 'other'
      return if College.find(college_id).present?

      errors[:college_id] << 'is invalid'
    end

    def save!
      name_updated = model.name != name

      sync
      model.college_id = nil if college_id == 'other'
      model.save!

      # Update Slack profile name if the name has been updated.
      Founders::UpdateSlackNameJob.perform_later(model.reload) if name_updated
    end
  end
end
