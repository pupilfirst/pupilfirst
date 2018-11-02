# This is a very permissive validator, requiring only that numbers be 10-16 digits with an optional + at the beginning.
class MobileNumberValidator < ActiveModel::EachValidator
  REGULAR_EXPRESSION = /\A\+?[0-9]{8,16}$\z/.freeze
  FORM_EXPRESSION = -'\+?[0-9]{8,16}'

  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors[attribute] << "doesn't look like a mobile phone number" unless value =~ /\A\+?[0-9]{8,16}$\z/
  end
end
