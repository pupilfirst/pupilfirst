module Mutations
  class UpdateCourse < ApplicationQuery
    class CourseMustBePresent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        course = Course.find_by(id: value[:id])

        return "Unable to find course with id: #{value[:id]}" if course.blank?
      end
    end
    include QueryAuthorizeSchoolAdmin
    include ValidateCourseEditable

    argument :id, ID, required: true

    validates CourseMustBePresent => {}

    description 'Update a course.'

    field :course, Types::CourseType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.update_course.success_notification')
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
