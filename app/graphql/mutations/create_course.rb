module Mutations
  class CreateCourse < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    include ValidateCourseEditable

    description 'Create a new course.'

    field :course, Types::CourseType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.create_course.success_notification')
      )

      { course: create_course }
    end

    def create_course
      Course.transaction do
        course = current_school.courses.create!(course_data)

        Courses::DemoContentService.new(course).execute

        course
      end
    end

    def resource_school
      current_school
    end
  end
end
