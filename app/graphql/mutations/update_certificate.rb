module Mutations
  class UpdateCertificate < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :margin, Int, required: true
    argument :name_offset_top, Int, required: true
    argument :font_size, Int, required: true
    argument :qr_corner, Types::QrCorner, required: true
    argument :qr_scale, Int, required: true
    argument :active, Boolean, required: true
    argument :name, String, required: true

    description "Update a certificate"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateCertificateMutator.new(context, params)

      success = if mutator.valid?
        mutator.update_certificate
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.update_certificate.success_notification'))
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
