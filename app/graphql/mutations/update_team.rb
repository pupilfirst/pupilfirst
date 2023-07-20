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
        return if @value[:student_ids].count >= 2

        'The team should have at least two students'
      end

      def students_should_belong_to_the_same_cohort
        old_team_member_ids = @team.students.pluck(:id).map(&:to_s)
        new_temp_student_ids = @value[:student_ids] - old_team_member_ids

        return if new_temp_student_ids.empty?

        if @team
             .cohort
             .students
             .where(id: new_temp_student_ids, team_id: nil)
             .count == new_temp_student_ids.count
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
        team
          .students
          .where.not(id: @params[:student_ids])
          .each { |student| student.update!(team_id: nil) }

        old_team = team.students.pluck(:id)

        students.map do |student|
          next if old_team.include?(student.id)
          student.update!(team: team)
        end
        students.each { |student| student.update!(team: team) }
      end
      team
    end

    def students
      @students ||= cohort.students.where(id: @params[:student_ids])
    end

    def cohort
      @cohort ||= team.cohort
    end

    def team
      @team ||= current_school.teams.find_by(id: @params[:team_id])
    end

    def resource_school
      team&.school
    end
  end
end
