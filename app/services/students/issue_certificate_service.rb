module Students
  # This service issues the active certificate for a course to the given student.
  #
  # for the `current` certificate, and creates an `issued_certificate` saving the current `name` of the student and
  # generating a `uuid` for the certificate.
  class IssueCertificateService
    def initialize(student)
      @student = student
    end

    def issue
      return if certificate.blank? || issued_certificate_exists?

      collisions = 0

      issued_certificate = certificate.issued_certificates.create!(
        user: user,
        name: user.name,
        serial_number: IssuedCertificates::SerialNumberService.generate
      )

      IssuedCertificateMailer.issued(issued_certificate).deliver_later
    rescue ActiveRecord::RecordNotUnique
      collisions += 1
      retry if collisions <= 5
      raise 'Number of certificate serial number collisions exceeded 5'
    end

    private

    def user
      @student.user
    end

    def issued_certificate_exists?
      certificate.issued_certificates.where(user: user).exists?
    end

    def certificate
      @certificate ||= course.certificates.active.first
    end

    def course
      @student.startup.course
    end
  end
end
