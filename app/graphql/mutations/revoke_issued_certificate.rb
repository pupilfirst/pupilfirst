module Mutations
  class RevokeIssuedCertificate < GraphQL::Schema::Mutation
    argument :issued_certificate_id, ID, required: true

    description "Revoke an issued certificate"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = RevokeIssuedCertificateMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, 'Done', 'Certificate revoked!')
        mutator.execute
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
