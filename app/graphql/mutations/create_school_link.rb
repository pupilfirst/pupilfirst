module Mutations
  class CreateSchoolLink < GraphQL::Schema::Mutation
    argument :kind, String, required: true
    argument :title, String, required: false
    argument :url, String, required: true

    description "Create a school link."

    field :school_link, Types::SchoolLink, null: true
    field :errors, [Types::CreateSchoolLinkError], null: true

    def resolve(params)
      mutator = CreateSchoolLinkMutator.new(context, params)

      if mutator.valid?
        { school_link: mutator.create_school_link, errors: nil }
      else
        { school_link: nil, errors: mutator.error_messages }
      end
    end
  end
end
