module Mutations
  class CloneLevel < GraphQL::Schema::Mutation
    argument :level_id, ID, required: true
    argument :clone_into_course_id, ID, required: true

    description "Clone level into given course"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CloneLevelMutator.new(context, params)

      if mutator.valid?
        mutator.clone_level
        mutator.notify(:success,
          I18n.t('shared.done_exclamation'),
          I18n.t('mutations.clone_level.success_notification')
        )
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
