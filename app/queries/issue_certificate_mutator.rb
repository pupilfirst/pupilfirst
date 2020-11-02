class IssueCertificateMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :student_id, validates: { presence: true }
  property :certificate_id, validates: { presence: true }

  validate :issued_certificate_not_present

  def execute
    Certificate.transaction do
      Students::IssueCertificateService.new(student).issue(certificate: certificate, issuer: current_user)
    end
  end

  private

  def issued_certificate_not_present
    return if student.user.issued_certificates.where(certificate: course.certificates, revoked_at: nil).empty?

    errors[:base] << I18n.t('queries.issue_certificate_mutator.issued_error')
  end

  def resource_school
    student&.school
  end

  def certificate
    @certificate ||= course.certificates.find_by(id: certificate_id)
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end

  def course
    student&.course
  end
end
