module Admissions
  class FoundersForm < Reform::Form
    attr_accessor :current_founder

    collection :founders, populate_if_empty: Founder do
      property :id
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: EmailValidator::REGULAR_EXPRESSION, message: "doesn't look like an email" } }
      property :phone, validates: { presence: true, mobile_number: true }
      property :college_id
      property :college_text, validates: { length: { maximum: 250 } }
      property :delete, virtual: true
      property :invited, writeable: false
    end

    validate :minimum_two_founders_required
    validate :maximum_six_founders_allowed
    validate :do_not_repeat_founders
    validate :founder_must_have_college_id_or_text
    validate :team_lead_cannot_be_deleted
    validate :current_founder_cannot_be_deleted

    def team_lead_cannot_be_deleted
      team_lead = founders.find { |founder| Founder.find_by(id: founder.id).startup_admin? }
      errors[:base] << 'Team lead cannot be deleted.' if team_lead.delete == 'on'
    end

    def current_founder_cannot_be_deleted
      logged_in_founder = founders.find { |founder| founder.id.to_i == current_founder.id }
      errors[:base] << 'You cannot delete yourself.' if logged_in_founder.delete == 'on'
    end

    def maximum_six_founders_allowed
      if founders.count > 6
        errors[:base] << 'You can have maximum six founders.'
      end
    end

    def minimum_two_founders_required
      unpersisted_founders = founders.reject { |founder| founder.model.persisted? }
      persisted_founders = founders.select { |founder| founder.model.persisted? && founder.delete != 'on' }

      return if (unpersisted_founders + persisted_founders).count >= 2

      errors[:base] << 'You must have at least two founders.'
    end

    def do_not_repeat_founders
      previous_emails = []
      has_error = false

      founders.each do |founder|
        if previous_emails.include? founder.email
          has_error = true
          founder.errors[:email] << 'has been mentioned before'
        else
          previous_emails << founder.email
        end
      end

      errors[:base] << "It looks like you've repeated some founder email addresses." if has_error
    end

    def founder_must_have_college_id_or_text
      founders.each do |founder|
        next if founder.college_text.present?
        next if College.find_by(id: founder.college_id).present?

        errors[:base] << "Please pick a college for #{founder.name}."

        if founder.college_id.blank?
          founder.errors[:college_text] << "can't be blank"
        else
          founder.errors[:college_id] << 'must be selected'
        end
      end
    end

    def prepopulate
      self.founders = founders.map do |existing_founder|
        # Force email to value from database.
        existing_founder.email = model.founders.find(existing_founder.id).email if existing_founder.id.present?

        existing_founder
      end

      self.founders += model.invited_founders
    end

    def save
      founders.each do |founder|
        if founder.id.present?
          update_founder(founder)
        else
          invite_founder(founder)
        end
      end
      Intercom::FounderTaggingJob.perform_later(current_founder, 'Added Co-founders')
    end

    def invite_founder(founder)
      Founders::InvitationService.new(
        model,
        college_details(founder).merge(
          name: founder.name, email: founder.email, phone: founder.phone
        )
      ).execute
    end

    def update_founder(founder)
      persisted_founder = model.founders.find_by(id: founder.id) || model.invited_founders.find(founder.id)

      if founder.delete == 'on'
        if persisted_founder.startup == model
          persisted_founder.startup = nil
        elsif persisted_founder.invited_startup == model
          persisted_founder.invited_startup = nil
          persisted_founder.invitation_token = nil
        end

        persisted_founder.save!
      else
        persisted_founder.update!(college_details(founder).merge(name: founder.name, phone: founder.phone))
      end
    end

    def college_details(founder)
      if founder.college_text.present?
        { college_text: founder.college_text }
      else
        { college_id: founder.college_id }
      end
    end

    def college_names
      founders.each_with_object({}) do |founder, names|
        next if founder.college_id.nil?
        names[founder.college_id] = College.find(founder.college_id).name
      end
    end

    def founders_for_react
      founders.as_json.map { |c| c.slice('fields', 'errors') }
    end
  end
end
