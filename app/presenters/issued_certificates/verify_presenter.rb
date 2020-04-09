module IssuedCertificates
  class VerifyPresenter < ApplicationPresenter
    def initialize(view_context, issued_certificate)
      @issued_certificate = issued_certificate
      super(view_context)
    end

    def props
      certificate.attributes.slice('margin', 'font_size', 'name_offset_top', 'qr_corner').merge(
        serial_number: serial_number,
        issued_to: @issued_certificate.name,
        issued_at: @issued_certificate.created_at,
        course_name: certificate.course.name,
        image_url: view.url_for(certificate.image)
      )
    end

    def serial_number
      @issued_certificate.serial_number
    end

    private

    def certificate
      @issued_certificate.certificate
    end
  end
end
