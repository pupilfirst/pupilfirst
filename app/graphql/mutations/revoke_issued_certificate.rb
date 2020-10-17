module Mutations
  class RevokeIssuedCertificate < GraphQL::Schema::Mutation
    argument :issued_certificate_id, ID, required: true

    description "Revoke a certificate issued to a student for a course"

    field :issued_certificate, Types::IssuedCertificateType, null: true

    def resolve(params)
      mutator = RevokeIssuedCertificateMutator.new(context, params)

      issued_certificate = if mutator.valid?
        mutator.notify(:success, 'Done', 'Certificate revoked successfully!')
        mutator.execute
      else
        mutator.notify_errors
        nil
      end

      { issued_certificate: issued_certificate }
    end
  end
end
