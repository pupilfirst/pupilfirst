class IssueCertificateMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :student_id, validates: { presence: true }
  property :certificate_id, validates: { presence: true }

  validate :student_must_not_have_issued_certificate
  validate :certificate_must_be_present

  def execute
    Certificate.transaction do
      Students::IssueCertificateService
        .new(student)
        .issue(certificate: certificate, issuer: current_user)
    end
  end

  private

  def student_must_not_have_issued_certificate
    if student
         .user
         .issued_certificates
         .where(certificate: course.certificates, revoked_at: nil)
         .empty?
      return
    end

    errors.add(:base, I18n.t('queries.issue_certificate_mutator.issued_error'))
  end

  def certificate_must_be_present
    return if certificate.present?

    errors.add(
      :base,
      I18n.t('queries.issue_certificate_mutator.certificate_error')
    )
  end

  def resource_school
    student&.school
  end

  def certificate
    @certificate ||= course.certificates.find_by(id: certificate_id)
  end

  def student
    @student ||= Student.find_by(id: student_id)
  end

  def course
    student&.course
  end
end
