class SlackChannelNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.length.in? 2..22
      record.errors[attribute] << 'channel name should be 1-21 characters'
    end

    unless /\A#[^A-Z\s.;!?]+\z/.match?(value)
      record.errors[attribute] << 'must start with a # and not contain uppercase, spaces or periods'
    end
  end
end
