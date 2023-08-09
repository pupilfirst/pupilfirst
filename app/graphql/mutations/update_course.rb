module Mutations
  class UpdateCourse < ApplicationQuery
    class CourseMustBePresent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        course = Course.find_by(id: value[:id])

        if course.blank?
          return(
            I18n.t(
              "mutations.update_course.unable_to_find_course",
              value: value[:id]
            )
          )
        end
      end
    end

    class DefaultCohortMustExist < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        course = Course.find_by(id: value[:id])

        return if course.blank?

        cohort = course.cohorts.find_by(id: value[:default_cohort_id])

        if cohort.blank?
          return(
            I18n.t(
              "mutations.update_course.select_valid_cohort",
              value: value[:default_cohort_id]
            )
          )
        end
      end
    end
    include QueryAuthorizeSchoolAdmin
    include ValidateCourseEditable

    argument :id, ID, required: true
    argument :default_cohort_id, ID, required: true

    validates CourseMustBePresent => {}
    validates DefaultCohortMustExist => {}

    description "Update a course."

    field :course, Types::CourseType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.update_course.success_notification")
      )

      { course: update_course }
    end

    def update_course
      course.update!(course_data)

      course
    end

    def resource_school
      course.school
    end

    def course
      Course.find_by(id: @params[:id])
    end
  end
end
