module Mutations
  class SendUpdateEmailToken < ApplicationQuery
    class NewEmailMustBeUnique < GraphQL::Schema::Validator
      def validate(_object, context, value)
        new_email = value[:new_email]
        current_user = context[:current_user]
        current_school = context[:current_school]

        user_with_new_email =
          User.find_by(email: new_email, school: current_school)
        if user_with_new_email.present? || new_email.blank? ||
             new_email == current_user.email
          return I18n.t("shared.email_exists_error")
        end
      end
    end

    class ValidRequest < GraphQL::Schema::Validator
      def validate(_object, context, _value)
        current_user = context[:current_user]
        time_since_last_mail =
          Time.zone.now -
            (current_user.update_email_token_sent_at.presence || 0)
        if time_since_last_mail < 2.minutes
          return I18n.t("users.update_email.frequent_request_error")
        end
      end
    end

    class ValidatePassword < GraphQL::Schema::Validator
      def validate(_object, context, value)
        current_user = context[:current_user]
        password = value[:password]
        if !current_user&.valid_password?(password)
          return I18n.t("users.update_email.invalid_password_error")
        end
      end
    end

    argument :new_email, String, required: true
    argument :password, String, required: true

    description "Update email for current user"

    field :success, Boolean, null: false

    validates NewEmailMustBeUnique => {}
    validates ValidRequest => {}
    validates ValidatePassword => {}

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.send_update_email_token.success_notification")
      )
      { success: send_update_email_token_email }
    end

    def send_update_email_token_email
      Users::MailUpdateEmailTokenService.new(
        current_user,
        @params[:new_email]
      ).execute
    end

    private

    def query_authorized?
      current_user.present?
    end
  end
end
