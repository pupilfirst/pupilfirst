module Mutations
  class ArchiveCourse < ApplicationQuery
    argument :id, ID, required: true

    description 'Archives a course.'

    field :success, Boolean, null: false

    def execute
      success =
        if valid_course?
          notify(
            :success,
            I18n.t('shared.done_exclamation'),
            I18n.t('mutations.archive_course.success_notification')
          )
          true
        else
          notify_errors
          false
        end

      { success: success }
    end

    def valid_course?
      return true unless course.archived?

      errors << 'Invalid course'
      false
    end

    def archive_course
      course.update!(
        archived_at: Time.zone.now,
        ends_at: course.ends_at.presence || Time.zone.now
      )

      course
        .startups
        .where(access_ends_at: nil)
        .update_all(access_ends_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    end

    private

    def resource_school
      course.school
    end

    def course
      Course.find_by(id: @params[:id])
    end

    def authorized?(**params)
      @params = params
      resource_school == current_school && current_school_admin.present?
    end
  end
end
