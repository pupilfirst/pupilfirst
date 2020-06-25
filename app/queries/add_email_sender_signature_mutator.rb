class AddEmailSenderSignatureMutator < ApplicationQuery
  property :name, validates: { presence: true, length: { minimum: 1, maximum: 100 } }
  property :email_address, validates: { presence: true, email: true }

  validate :school_must_not_have_email_sender_signature

  def add_email_sender_signature
    sender_signature_id = Schools::RegisterSenderSignatureService.new(current_school).register(name, email_address)

    configuration['emailSenderSignature'] = {
      name: name,
      email: email_address,
      senderSignatureId: sender_signature_id,
      confirmedAt: nil,
      lastCheckedAt: nil
    }

    current_school.update!(configuration: configuration)
    configuration['emailSenderSignature']
  end

  private

  def configuration
    @configuration ||= current_school.configuration.dup
  end

  def school_must_not_have_email_sender_signature
    return if current_school.configuration["emailSenderSignature"].blank?

    errors[:base] << "Delete the existing email sender signature before attempting to register a new one"
  end

  def authorized?
    current_school_admin.present?
  end
end
