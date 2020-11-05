module Mutations
  class IssueCertificate < GraphQL::Schema::Mutation
    argument :student_id, ID, required: true
    argument :certificate_id, ID, required: true

    description "Issue a certificate to a student"

    field :issued_certificate, Types::IssuedCertificateType, null: true

    def resolve(params)
      mutator = IssueCertificateMutator.new(context, params)

      issued_certificate = if mutator.valid?
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.issue_certificate.success_notification'))
        mutator.execute
      else
        mutator.notify_errors
        nil
      end

      { issued_certificate: issued_certificate }
    end
  end
end
