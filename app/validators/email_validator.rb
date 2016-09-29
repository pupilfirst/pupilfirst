class EmailValidator < ActiveModel::EachValidator
  REGULAR_EXPRESSION = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def validate_each(record, attribute, value)
    unless value =~ REGULAR_EXPRESSION
      record.errors[attribute] << 'does not look like an email address'
    end
  end
end
