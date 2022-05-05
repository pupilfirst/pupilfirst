class DeleteCertificateMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id

  validate :must_not_have_been_issued

  def delete_certificate
    certificate.destroy!
  end

  private

  def must_not_have_been_issued
    return if certificate.issued_certificates.empty?

    errors[:base] << I18n.t('queries.delete_certificate_mutator.issued_error')
  end

  def resource_school
    certificate&.course&.school
  end

  def certificate
    @certificate ||= Certificate.find_by(id: id)
  end
end
