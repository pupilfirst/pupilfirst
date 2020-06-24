module Mutations
  class AddFromAddress < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :email_address, String, required: true

    description "Register a new 'from' email address for a school."

    field :from_address, Types::FromAddress, null: true

    def resolve(params)
      mutator = AddFromAddressMutator.new(context, params)

      from_address = if mutator.valid?
        mutator.notify(:success, 'Done!', 'Please check your inform for a confirmation email.')
        mutator.add_from_address
      else
        mutator.notify_errors
        nil
      end

      { from_address: from_address }
    end
  end
end
