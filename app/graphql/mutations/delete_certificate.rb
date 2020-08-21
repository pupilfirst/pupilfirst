module Mutations
  class DeleteCertificate < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Delete an un-issued certificate"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteCertificateMutator.new(context, params)

      success = if mutator.valid?
        mutator.delete_certificate
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.delete_certificate.success_notification'))
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
