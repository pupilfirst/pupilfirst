module Mutations
  class SendUpdateEmailToken < ApplicationQuery
    class NewEmailMustBeUnique < GraphQL::Schema::Validator
      def validate(_object, context, value)
        new_email = value[:new_email]
        current_user = context[:current_user]
        current_school = context[:current_school]

        user_with_new_email = User.find_by(email: new_email, school: current_school)
        if user_with_new_email.present? || new_email.blank? || new_email == current_user.email
          return I18n.t('shared.email_exists_error')
        end
      end
    end

    argument :new_email, String, required: true

    description 'Update a email.'

    field :success, Boolean, null: false

    validates NewEmailMustBeUnique => {}

    def resolve(_params)
      { success: send_update_email_token_email }
    end

    def send_update_email_token_email
      Users::MailUpdateEmailTokenService.new(
        current_school,
        current_user,
        @params[:new_email]
      ).execute
    end

    def token_generated_at
      current_user&.update_email_token_sent_at
    end

    private

    def query_authorized?
      current_user.present?
    end

    def resource_school
      current_user&.school
    end
  end
end
