module Mutations
  class AddEmailSenderSignature < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :email_address, String, required: true

    description "Register a new 'from' email address for a school."

    field :email_sender_signature, Types::EmailSenderSignature, null: true

    def resolve(params)
      mutator = AddEmailSenderSignatureMutator.new(context, params)

      email_sender_signature = if mutator.valid?
        mutator.notify(:success, 'Done!', 'Please check your inform for a confirmation email.')
        mutator.add_email_sender_signature
      else
        mutator.notify_errors
        nil
      end

      { email_sender_signature: email_sender_signature }
    end
  end
end
