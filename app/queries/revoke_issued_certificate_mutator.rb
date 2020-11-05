class RevokeIssuedCertificateMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :issued_certificate_id, validates: { presence: true }

  def execute
    Certificate.transaction do
      Students::RevokeIssuedCertificateService.new(issued_certificate).revoke(revoker: current_user)
    end
  end

  private

  def resource_school
    issued_certificate&.course&.school
  end

  def issued_certificate
    @issued_certificate ||= IssuedCertificate.find_by(id: issued_certificate_id)
  end
end
