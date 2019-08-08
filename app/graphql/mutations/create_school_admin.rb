module Mutations
  class CreateSchoolAdmin < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :email, String, required: true

    description "Create a new school admin"

    field :avatar_url, String, null: true

    def resolve(params)
      mutator = CreateSchoolAdminMutator.new(params, context)

      if mutator.valid?
        { avatar_url: mutator.save }
      else
        mutator.notify_errors
        { avatar_url: nil }
      end
    end
  end
end
