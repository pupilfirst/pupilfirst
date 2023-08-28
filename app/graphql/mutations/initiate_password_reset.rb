module Mutations
  class InitiatePasswordReset < ApplicationQuery
    class ValidateTokenGeneration < GraphQL::Schema::Validator
      def validate(_object, context, value)
        user = context[:current_school].users.with_email(value[:email]).first
        if user&.reset_password_sent_at.present?
          time_since_last_mail = Time.zone.now - user.reset_password_sent_at
          if time_since_last_mail < 2.minutes
            return(
              I18n.t("mutations.initiate_password_reset.token_generation_error")
            )
          end
        end
      end
    end

    class ValidateBouncedEmail < GraphQL::Schema::Validator
      def validate(_object, context, value)
        user = context[:current_school].users.with_email(value[:email]).first
        if user&.email_bounced?
          return I18n.t("mutations.initiate_password_reset.email_bounced_error")
        end
      end
    end

    argument :email, String, required: true

    description "Initiates the password reset process for a user."

    field :success, Boolean, null: false

    validates ValidateTokenGeneration => {}
    validates ValidateBouncedEmail => {}

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.initiate_password_reset.success_notification")
      )
      Users::MailResetPasswordTokenService.new(
        current_school,
        current_user
      ).execute

      { success: true }
    end

    def query_authorized?
      current_user.present? && current_user.email == @params[:email]
    end
  end
end
