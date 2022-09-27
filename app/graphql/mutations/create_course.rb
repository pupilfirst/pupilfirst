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

        default_cohort =
          Cohort.create!(
            name: 'Purple (Auto-generated)',
            description:
              "Auto generated cohort for active students in #{course.name}",
            course_id: course.id
          )

        course.update!(default_cohort_id: default_cohort.id)

        course
      end
    end

    def resource_school
      current_school
    end
  end
end
