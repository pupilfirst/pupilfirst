module Schools
  class ImagesForm < Reform::Form
    VALID_MIME_TYPES = %w[image/jpeg image/png].freeze

    property :logo_on_light_bg, virtual: true, validates: { file_content_type: { allow: VALID_MIME_TYPES }, file_size: { less_than: 2.megabytes } }, allow_nil: true
    property :logo_on_dark_bg, virtual: true, validates: { file_content_type: { allow: VALID_MIME_TYPES }, file_size: { less_than: 2.megabytes } }, allow_nil: true
    property :icon, virtual: true, validates: { file_content_type: { allow: VALID_MIME_TYPES }, file_size: { less_than: 2.megabytes } }, allow_nil: true

    def save
      model.logo_on_light_bg.attach(logo_on_light_bg) if logo_on_light_bg.present?
      model.logo_on_dark_bg.attach(logo_on_dark_bg) if logo_on_dark_bg.present?
      model.icon.attach(icon) if icon.present?
    end
  end
end
