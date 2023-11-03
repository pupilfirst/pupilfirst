module Mutations
  class CreateUserStanding < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :student_id, ID, required: true
    argument :reason, String, required: true
    argument :standing_id, ID, required: true

    description "Create a new standing log"

    field :user_standing, Types::UserStandingType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.create_standing_log.success_notification")
      )
      { user_standing: create_user_standing }
    end

    private

    def create_user_standing
      UserStanding.transaction do
        UserStanding.create!(
          user_id: student.user.id,
          reason: @params[:reason],
          standing_id: @params[:standing_id],
          creator: current_user
        )
      end
    end

    def resource_school
      student&.school
    end

    def student
      @student ||= Student.find(@params[:student_id])
    end
  end
end
