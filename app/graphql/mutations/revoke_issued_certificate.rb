module Mutations
  class RevokeIssuedCertificate < GraphQL::Schema::Mutation
    argument :issued_certificate_id, ID, required: true

    description 'Revoke an issued certificate'

    field :revoked_certificate, Types::IssuedCertificateType, null: true

    def resolve(params)
      mutator = RevokeIssuedCertificateMutator.new(context, params)

      revoked_certificate =
        if mutator.valid?
          mutator.notify(
            :success,
            I18n.t('shared.notifications.done_exclamation'),
            I18n.t('mutations.revoke_issued_certificate.success_notification')
          )
          mutator.execute
        else
          mutator.notify_errors
          nil
        end

      { revoked_certificate: revoked_certificate }
    end
  end
end
