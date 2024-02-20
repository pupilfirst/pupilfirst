module Mutations
  class ArchiveUserStanding < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :id, ID, required: true

    description "Archive a standing log"

    field :success, Boolean, null: false

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.archive_user_standing.success_notification")
      )
      { success: archive_standing_log }
    end

    private

    def standing_log
      @standing_log ||= UserStanding.find_by(id: @params[:id])
    end

    def archive_standing_log
      standing_log.update!(archived_at: Time.zone.now, archiver: current_user)
    end

    def resource_school
      standing_log&.user&.school
    end

    def allow_token_auth?
      true
    end
  end
end
