module Mutations
  class DestroyTeam < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :team_id, ID, required: false

    description 'Destroy team'

    field :success, Boolean, null: false

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.destroy_team.success_notification')
      )
      destroy_team
      { success: team.destroyed? }
    end

    private

    def destroy_team
      Team.transaction do
        team.students.each { |student| student.update!(team: nil) }
        team.reload.destroy!
      end
    end

    def team
      @team ||= current_school.teams.find(@params[:team_id])
    end

    def resource_school
      team&.school
    end
  end
end
