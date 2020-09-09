module IssuedCertificates
  class VerifyPresenter < ApplicationPresenter
    def initialize(view_context, issued_certificate)
      @issued_certificate = issued_certificate
      super(view_context)
    end

    def props
      {
        issued_certificate: issued_certificate_details,
        verify_image_url: view.image_path('issued_certificates/verify.png'),
        current_user: user.present? && user == current_user
      }
    end

    def serial_number
      @issued_certificate.serial_number
    end

    private

    def user
      @issued_certificate.user
    end

    def issued_certificate_details
      certificate.attributes.slice('margin', 'font_size', 'name_offset_top', 'qr_corner', 'qr_scale').merge(
        serial_number: serial_number,
        issued_to: @issued_certificate.name,
        profile_name: user&.name || @issued_certificate.name,
        issued_at: @issued_certificate.created_at,
        course_name: certificate.course.name,
        image_url: view.url_for(certificate.image)
      )
    end

    def certificate
      @issued_certificate.certificate
    end
  end
end
