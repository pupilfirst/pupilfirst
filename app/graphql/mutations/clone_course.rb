module Mutations
  class CloneCourse < ApplicationQuery
    include QueryAuthorizeSchoolAdmin

    argument :id, ID, required: true

    field :success, Boolean, null: false

    description 'Make a clone of a given course.'

    def resolve(_params)
      ::Courses::CloneCourseJob.perform_later(course.id)
      notify(:success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.clone_course.success_notification')
      )
      { success: true }
    end

    private

    def resource_school
      course.school
    end

    def course
      Course.find_by(id: @params[:id])
    end
  end
end
