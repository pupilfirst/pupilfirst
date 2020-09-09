module Courses
  class CreateCertificateForm < Reform::Form
    property :image, virtual: true, validates: { presence: true, file_size: { less_than: 5.megabytes }, image: true }
    property :name, virtual: true, validates: { length: { maximum: 30, blank: true } }

    def save
      model.certificates.create!(
        image: image,
        name_offset_top: 45,
        font_size: 100,
        margin: 0,
        active: false,
        name: normalized_name,
        qr_corner: 'Hidden',
        qr_scale: 100
      )
    end

    private

    def normalized_name
      if name.present?
        name.strip
      else
        Time.zone.now.strftime('%-d %b %Y %-l:%M %p')
      end
    end
  end
end
