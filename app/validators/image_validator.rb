class ImageValidator < ActiveModel::EachValidator
  IMAGE_TYPE_WHITELIST = %i[jpeg png gif].freeze
  IMAGE_MAX_WIDTH = 4096
  IMAGE_MAX_HEIGHT = 4096

  def validate_each(record, attribute, value)
    return if value.blank?

    image = FastImage.new(value)

    return if image_type_valid?(image) && pixel_dimensions_valid?(image)

    record.errors[attribute] << (options[:message] || "must be a JPEG, PNG, or GIF, less than 4096 pixels wide or high")
  end

  def image_type_valid?(image)
    image.type && IMAGE_TYPE_WHITELIST.include?(image.type)
  end

  def pixel_dimensions_valid?(image)
    image.size &&
      image.size[0] <= IMAGE_MAX_WIDTH &&
      image.size[1] <= IMAGE_MAX_HEIGHT
  end
end
