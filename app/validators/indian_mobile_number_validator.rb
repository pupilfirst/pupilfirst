class IndianMobileNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors[attribute] << 'must be a 10-digit mobile phone number' unless value =~ /\A[789][0-9]{9}\z/
  end
end
