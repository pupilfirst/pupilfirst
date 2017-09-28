# This validator ensures that uploaded images are, in fact, images and that their size is less than 4096x4096.
# This prevents the crash that would otherwise occur when Carrierwave bomb-shelter steps in to block image processing.
class RasterImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return unless value.respond_to?(:tempfile)

    image = FastImage.new(value.tempfile)

    unless image.type.in?(image_type_whitelist)
      record.errors[attribute] << "must be one of #{image_types_for_error}"
      return
    end

    width, height = image.size

    if width > 4096 || height > 4096
      record.errors[attribute] << 'must be smaller than 4096x4096'
    end
  end

  private

  def image_types_for_error
    image_type_whitelist.map { |t| t.to_s.upcase }.join(', ')
  end

  def image_type_whitelist
    %i[jpeg png gif]
  end
end
