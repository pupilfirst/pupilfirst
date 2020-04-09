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
      return if certificate.blank?

      collisions = 0

      certificate.issued_certificates.create!(
        user: user,
        name: user.name,
        serial_number: new_serial_number
      )
    rescue ActiveRecord::RecordNotUnique
      collisions += 1
      retry if collisions <= 5
      raise 'Number of certificate serial number collisions exceeded 5'
    end

    private

    def user
      @student.user
    end

    # Returns a unique 13-char serial number, with ~2.2B possibilities per day.
    def new_serial_number
      date = Time.now.utc.strftime("%y%m%d")
      token = rand(2_176_782_336).to_s(36).rjust(6, '0').upcase

      "#{date}-#{token}"
    end

    def certificate
      course.certificates.active.first
    end

    def course
      @student.startup.course
    end
  end
end
