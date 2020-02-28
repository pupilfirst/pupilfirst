module Mutations
  class CreateSchoolAdmin < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :email, String, required: true

    description "Create a new school admin"

    field :school_admin, Types::UserProxyType, null: true

    def resolve(params)
      mutator = CreateSchoolAdminMutator.new(context, params)

      if mutator.valid?
        { school_admin: mutator.create_school_admin }
      else
        mutator.notify_errors
        { school_admin: nil }
      end
    end
  end
end
