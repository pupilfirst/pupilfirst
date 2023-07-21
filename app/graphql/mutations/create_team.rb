module Mutations
  class CreateTeam < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :cohort_id, ID, required: false
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

    description 'Create a new team'

    field :team, Types::TeamType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.create_team.success_notification')
      )

      { team: create_team }
    end

    class ValidateTeamCreatable < GraphQL::Schema::Validator
      include ValidatorCombinable

      def validate(_object, context, value)
        @cohort =
          context[:current_school].cohorts.find_by(id: value[:cohort_id])
        @value = value

        combine(size_grater_than_two, students_should_belong_to_the_same_cohort)
      end

      def size_grater_than_two
        return if @value[:student_ids].count >= 2

        'You need to add more than two students to create a team'
      end

      def students_should_belong_to_the_same_cohort
        if @cohort
             .students
             .where(id: @value[:student_ids], team_id: nil)
             .count == @value[:student_ids].count
          return
        end

        'Each student should belong to the same cohort and should not be in a team'
      end
    end

    validates ValidateTeamCreatable => {}

    private

    def create_team
      Team.transaction do
        team = cohort.teams.create!(name: @params[:name], cohort: cohort)

        students.each { |student| student.update!(team: team) }

        team
      end
    end

    def students
      @students ||= cohort.students.where(id: @params[:student_ids])
    end

    def cohort
      @cohort ||= current_school.cohorts.find(@params[:cohort_id])
    end

    def resource_school
      cohort&.school
    end
  end
end
