module Mutations
  class UpdateTeam < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :team_id, ID, required: false
    argument :name,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 50
               }
             }
    argument :student_ids, [ID], required: true

    description 'Update a new team'

    field :team, Types::TeamType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.update_team.success_notification')
      )

      { cohort: update_team }
    end

    class ValidateTeamEditable < GraphQL::Schema::Validator
      include ValidatorCombinable

      def validate(_object, context, value)
        @team = context[:current_school].teams.find_by(id: value[:team_id])
        @value = value

        combine(size_grater_than_two, students_should_belong_to_the_same_cohort)
      end

      def size_grater_than_two
        return if @value[:student_ids].count > 2

        'The team should have at least two students'
      end

      def students_should_belong_to_the_same_cohort
        if @team
             .cohort
             .founders
             .where(id: @value[:student_ids], team_id: nil)
             .count == @value[:student_ids].count
          return
        end

        'Each student should belong to the same cohort and should not be in a team'
      end
    end

    validates ValidateTeamEditable => {}

    private

    def update_team
      Team.transaction do
        team.update!(name: @params[:name]) if @params[:name] != team.name

        # Remove old team members
        team.founders.where.not(id: @params[:student_ids]).destroy_all
        old_team = team.founders.pluck(:id)

        students.map do |student|
          next if old_team.include?(student.id)
          student.update!(team: team)
        end
        students.each { |student| student.update!(team: team) }
      end
      team
    end

    def students
      @students ||= cohort.founders.where(id: @params[:student_ids])
    end

    def team
      @team ||= current_school.cohorts.find(@params[:team_id])
    end

    def resource_school
      team&.school
    end
  end
end
