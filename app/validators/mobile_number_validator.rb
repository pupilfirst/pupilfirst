# This is a very permissive validator, requiring only that numbers be 10-16 digits with an optional + at the beginning.
class MobileNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "doesn't look like a mobile phone number" unless value =~ /\A\+?[0-9]{10,16}$\z/
  end
end
