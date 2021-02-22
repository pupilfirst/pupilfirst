module Mutations
  class UnarchiveCourse < GraphQL::Schema::Mutation
    include QueryAuthorizeSchoolAdmin

    argument :id, ID, required: true

    description 'Un-archives a course.'

    field :success, Boolean, null: false

    def resolve(_params)
      unarchive_course
      notify(
        :success,
        I18n.t('shared.done_exclamation'),
        I18n.t('mutations.unarchive_course.success_notification')
      )
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
