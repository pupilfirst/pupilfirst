module Mutations
  class ArchiveCourse < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    include DevelopersNotifications

    class CourseMustNotBeArchived < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        course = Course.find_by(id: value[:id])

        return "Unable to find course with id: #{value[:id]}" if course.blank?

        return 'Course is already archived' if course.archived?
      end
    end

    argument :id, ID, required: true

    description 'Archives a course.'

    validates CourseMustNotBeArchived => {}

    field :success, Boolean, null: false

    def resolve(_params)
      archive_course
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.archive_course.success_notification')
      )
      publish(course, :course_archived, current_user, course)
      { success: true }
    end

    def archive_course
      Course.transaction do
        course.update!(archived_at: Time.zone.now)

        course.cohorts.active.update_all(ends_at: course.archived_at) # rubocop:disable Rails/SkipsModelValidations
      end
    end

    def resource_school
      course.school
    end

    def course
      Course.find_by(id: @params[:id])
    end
  end
end
