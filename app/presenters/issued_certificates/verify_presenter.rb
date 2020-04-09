module IssuedCertificates
  class VerifyPresenter < ApplicationPresenter
    def initialize(view_context, issued_certificate)
      @issued_certificate = issued_certificate

      super(view_context)
    end

    def serial_number
      @issued_certificate.serial_number
    end

    def issued_to
      @issued_certificate.name
    end

    def issued_on
      @issued_certificate.created_at.strftime('%B %e, %Y')
    end

    def course_name
      @issued_certificate.certificate.course.name
    end
  end
end
