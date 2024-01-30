module Mutations
  class CreateUserStanding < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :user_id, ID, required: true
    argument :reason, String, required: true
    argument :standing_id, ID, required: true

    description "Create a new standing log"

    field :user_standing, Types::UserStandingType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.create_user_standing.success_notification")
      )
      { user_standing: create_user_standing }
    end

    class ValidateStandingExists < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        if !Standing.exists?(id: value[:standing_id])
          return(
            I18n.t("mutations.create_user_standing.standing_not_found_error")
          )
        end
      end
    end

    class ValidateStandingIsNotArchived < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        if Standing.find_by(id: value[:standing_id])&.archived_at.present?
          return(
            I18n.t("mutations.create_user_standing.standing_archived_error")
          )
        end
      end
    end

    validates ValidateStandingExists => {}
    validates ValidateStandingIsNotArchived => {}

    private

    def create_user_standing
      user_standing =
        user.user_standings.create!(
          reason: @params[:reason],
          standing_id: @params[:standing_id],
          creator: current_user
        )

      send_email

      user_standing
    end

    def send_email
      current_standing, previous_standing = user_standings.map(&:standing)

      previous_standing = previous_standing || resource_school.default_standing

      UserMailer.email_change_in_user_standing(
        user,
        current_standing.name,
        previous_standing.name,
        @params[:reason]
      ).deliver_later
    end

    def user_standings
      UserStanding
        .where(user: user.id, archived_at: nil)
        .order(created_at: :desc)
        .limit(2)
    end

    def resource_school
      user&.school
    end

    def allow_token_auth?
      true
    end

    def user
      @user ||= User.find_by(id: @params[:user_id])
    end
  end
end
