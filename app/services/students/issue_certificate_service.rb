module Students
  # This service issues the active certificate for a course to the given student.
  #
  # for the `current` certificate, and creates an `issued_certificate` saving the current `name` of the student and
  # generating a `uuid` for the certificate.
  class IssueCertificateService
    def initialize(student, certificate = nil, issuer = nil)
      @student = student
      @certificate = certificate
      @issuer = issuer
    end

    def issue
      return if certificate_to_issue.blank? || issued_certificate_exists?

      collisions = 0

      begin
        issued_certificate = certificate_to_issue.issued_certificates.create!(
          user: user,
          name: user.name,
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
      certificate_to_issue.issued_certificates.where(user: user, revoked_at: nil).exists?
    end

    def active_certificate
      course.certificates.active.first
    end

    def certificate_to_issue
      @certificate_to_issue ||= @certificate || active_certificate
    end

    def course
      @student.startup.course
    end
  end
end
