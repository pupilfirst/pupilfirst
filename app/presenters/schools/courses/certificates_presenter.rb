module Schools
  module Courses
    class CertificatesPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def props
        {
          course: course_details,
          certificates: certificates,
        }
      end

      def certificates
        active_certificate = @course.certificates.active.first

        inactive_certificates = @course.certificates.inactive
          .where.not(id: active_certificate.id)
          .order(updated_at: :desc)
          .limit(9)

        latest_certificates = [active_certificate] + inactive_certificates.to_a

        latest_certificates.map { |c| certificate_details(c) }
      end

      private

      def certificate_details(certificate)
        certificate.attributes.slice(
          'id', 'qr_corner', 'qr_scale', 'name_offset_top', 'font_size', 'margin', 'active', 'created_at', 'updated_at'
        ).merge(
          image_url: certificate.image_path
        )
      end

      def course_details
        {
          id: @course.id,
          name: @course.name
        }
      end
    end
  end
end
