module Mutations
  class CloneLevel < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :level_id, ID, required: true
    argument :clone_into_course_id, ID, required: true

    description 'Clone level into given course'

    field :success, Boolean, null: false

    def resolve(_params)
      clone_level
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.clone_level.success_notification')
      )
      { success: true }
    end

    def clone_level
      ::Levels::CloneLevelJob.perform_later(level.id, target_course.id)
    end

    def resource_school
      return unless level&.course&.school === target_course&.school

      target_course&.school
    end

    def target_course
      @target_course ||= Course.find_by(id: @params[:clone_into_course_id])
    end

    def level
      @level ||= Level.find_by(id: @params[:level_id])
    end
  end
end
