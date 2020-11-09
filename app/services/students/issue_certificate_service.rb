module Students
  # This service issues the active certificate for a course to the given student.
  #
  # for the `current` certificate, and creates an `issued_certificate` saving the current `name` of the student and
  # generating a `uuid` for the certificate.
  class IssueCertificateService
    def initialize(student)
      @student = student
    end

    def issue(certificate: nil, issuer: nil)
      certificate_to_issue = certificate || active_certificate

      return if certificate_to_issue.blank? || issued_certificate_exists?

      collisions = 0

      begin
        issued_certificate = certificate_to_issue.issued_certificates.create!(
          user: user,
          name: user.name,
          issuer: issuer,
          serial_number: IssuedCertificates::SerialNumberService.generate
        )
      rescue ActiveRecord::RecordNotUnique
        collisions += 1
        retry if collisions <= 5
        raise 'Number of certificate serial number collisions exceeded 5'
      end

      IssuedCertificateMailer.issued(issued_certificate).deliver_later

      issued_certificate
    end

    private

    def user
      @student.user
    end

    def issued_certificate_exists?
      user.issued_certificates.exists?(certificate: course.certificates, revoked_at: nil)
    end

    def active_certificate
      course.certificates.active.first
    end

    def course
      @student.startup.course
    end
  end
end
