module Mutations
  class CreateSchoolLink < GraphQL::Schema::Mutation
    argument :kind, String, required: true
    argument :title, String, required: false
    argument :url, String, required: true

    description "Create a school link."

    field :school_link, Types::SchoolLink, null: false

    def resolve(params)
      mutator = CreateSchoolLinkMutator.new(params, context)

      if mutator.valid?
        { school_link: mutator.create_school_link }
      else
        raise "Invalid request. Errors: #{mutator.error_codes}"
      end
    end
  end
end
