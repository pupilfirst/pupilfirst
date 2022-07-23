module Mutations
  class UpdateTarget < ApplicationQuery
    include QueryAuthorizeAuthor
    include ValidateTargetEditable

    description 'Update a target'

    field :sort_index, Integer, null: true

    def resolve(_params)
      updated_target =
        ::Targets::UpdateService.new(target).execute(target_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.update_target.success_notification')
      )
      { sort_index: updated_target.sort_index }
    end

    def resource_school
      course&.school
    end

    def target
      @target ||= Target.find_by(id: @params[:id])
    end

    def course
      target&.course
    end
  end
end
