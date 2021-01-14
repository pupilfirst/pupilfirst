module Mutations
  class RevokeIssuedCertificate < GraphQL::Schema::Mutation
    argument :issued_certificate_id, ID, required: true

    description "Revoke an issued certificate"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = RevokeIssuedCertificateMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.revoke_issued_certificate.success_notification'))
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
