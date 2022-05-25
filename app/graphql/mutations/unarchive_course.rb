module Mutations
  class UnarchiveCourse < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    include DevelopersNotifications

    argument :id, ID, required: true

    description 'Un-archives a course.'

    field :success, Boolean, null: false

    def resolve(_params)
      unarchive_course
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.unarchive_course.success_notification')
      )
      publish(course, :course_unarchived, current_user, course)
      { success: true }
    end

    def unarchive_course
      return if course.live?

      course.update!(archived_at: nil)
    end

    def resource_school
      course.school
    end

    def course
      Course.find_by(id: @params[:id])
    end
  end
end
