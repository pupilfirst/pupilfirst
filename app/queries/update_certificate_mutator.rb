class UpdateCertificateMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :margin, validates: { numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 20 } }
  property :name_offset_top, validates: { numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 95 } }
  property :font_size, validates: { numericality: { greater_than_or_equal_to: 75, less_than_or_equal_to: 150 } }
  property :qr_corner, validates: { presence: true }
  property :qr_scale, validates: { numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: 150 } }
  property :active
  property :name, validates: { length: { minimum: 1, maximum: 30 } }

  def update_certificate
    Certificate.transaction do
      if active && !certificate.active
        Certificate.active.update(active: false)
      end

      certificate.update!(
        margin: margin,
        name_offset_top: name_offset_top,
        font_size: font_size,
        qr_corner: qr_corner,
        qr_scale: qr_scale,
        active: active,
        name: name
      )
    end
  end

  private

  def resource_school
    certificate&.course&.school
  end

  def certificate
    @certificate ||= Certificate.find_by(id: id)
  end
end
