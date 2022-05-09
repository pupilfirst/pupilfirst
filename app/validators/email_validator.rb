class EmailValidator < ActiveModel::EachValidator
  REGULAR_EXPRESSION = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  def validate_each(record, attribute, value)
    if value !~ REGULAR_EXPRESSION || value.length > 254
      record.errors.add(
        attribute,
        options[:message] || 'must be in valid format'
      )
    end
  end
end
