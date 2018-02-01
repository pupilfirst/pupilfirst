module Admissions
  class FoundersForm < Reform::Form
    attr_accessor :current_founder

    collection :founders, populate_if_empty: Founder do
      property :id, writeable: false
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: EmailValidator::REGULAR_EXPRESSION, message: "doesn't look like an email" } }
      property :phone, validates: { presence: true, mobile_number: true }
      property :college_id
      property :college_text, validates: { length: { maximum: 250 } }
      property :delete, virtual: true
      property :invited, writeable: false
      property :ignore_email_hint, virtual: true
      property :replacement_hint, virtual: true
    end

    validate :maximum_three_team_members_allowed
    validate :do_not_repeat_team_members
    validate :team_member_must_have_college_id_or_text
    validate :team_lead_cannot_be_deleted
    validate :current_team_member_cannot_be_deleted
    validate :cannot_invite_admitted_team_members
    validate :email_should_be_valid

    def cannot_invite_admitted_team_members
      has_error = false

      founders.each do |founder|
        if Founder.with_email(founder.email)&.admitted?
          has_error = true
          founder.errors[:email] << 'is already an admitted SV.CO user'
        end
      end

      errors[:base] << "It looks like you've attempted to invite users who have already joined the SV.CO program." if has_error
    end

    def team_lead_cannot_be_deleted
      team_lead = founders.find { |founder| Founder.find_by(id: founder.id).team_lead? }
      errors[:base] << 'Team lead cannot be deleted.' if team_lead.delete == 'on'
    end

    def current_team_member_cannot_be_deleted
      logged_in_founder = founders.find { |founder| founder.id.to_i == current_founder.id }
      errors[:base] << 'You cannot delete yourself.' if logged_in_founder.delete == 'on'
    end

    def maximum_three_team_members_allowed
      if founders.count > 3
        errors[:base] << 'You can have maximum three team members (including yourself).'
      end
    end

    def do_not_repeat_team_members
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

      errors[:base] << "It looks like you've repeated some team member email addresses." if has_error
    end

    def team_member_must_have_college_id_or_text
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

    def email_should_be_valid
      has_error = false
      founders.each do |founder|
        next if founder.id.present?
        email_validation = EmailInquire.validate(founder.email)
        next if email_validation.valid?
        next if founder.ignore_email_hint == 'true'
        has_error = true

        if email_validation.hint?
          founder.errors[:email] << 'email could be incorrect'
          founder.replacement_hint = email_validation.replacement
        else
          founder.errors[:email] << 'email addresses not valid'
        end
      end
      errors[:base] << "It looks like you've entered an invalid email address" if has_error
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

      # If the cofounder addition target is not marked as completed, and the number of team members in the startup is
      # greater than or equal to two, set the team member addition target as complete.
      team_member_count = current_founder.startup.billing_founders_count
      team_member_addition_incomplete = cofounder_addition_target.status(current_founder) != Targets::StatusService::STATUS_COMPLETE

      if team_member_count >= 2 && team_member_addition_incomplete
        Admissions::CompleteTargetService.new(current_founder, Target::KEY_COFOUNDER_ADDITION).execute
      end
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

    private

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_COFOUNDER_ADDITION)
    end
  end
end
