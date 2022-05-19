module Mutations
  class UpdateSchoolLink < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :url, String, required: false

    description 'Update school header/footer/social links'

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateSchoolLinksMutator.new(context, params)
      if mutator.valid?
        { success: mutator.save }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
