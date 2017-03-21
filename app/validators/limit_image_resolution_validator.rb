# This validator disallows images greater than 4096x4096. This prevents the crash that would otherwise occur when
# Carrierwave bombshelter steps in to block image processing.
class LimitImageResolutionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return unless value.respond_to?(:tempfile)
    return if FastImage.type(value.tempfile).blank?

    width, height = FastImage.size(value.tempfile)

    if width > 4096 || height > 4096
      record.errors[attribute] << 'must be smaller than 4096x4096'
    end
  end
end
