class EmailValidator < ActiveModel::EachValidator
  REGULAR_EXPRESSION = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  def validate_each(record, attribute, value)
    unless REGULAR_EXPRESSION.match?(value)
      record.errors[attribute] << (options[:message] || 'must be in valid format')
    end
  end
end
