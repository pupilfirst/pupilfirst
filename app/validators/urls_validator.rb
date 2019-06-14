class UrlsValidator < ActiveModel::Validations::UrlValidator
  def validate_each(record, attribute, values)
    # Unfreeze options, so that we can mess with the message in here.
    @options = @options.dup

    values.each_with_index do |value, index|
      options[:message] = "Link #{index + 1} is invalid"
      super(record, attribute, value)
    end
  end
end
