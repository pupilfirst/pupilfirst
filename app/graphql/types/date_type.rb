module Types
  # Deprecated! Use gem's GraphQL::Types::ISO8601Date class instead.
  class DateType < GraphQL::Schema::Scalar
    description "An ISO 8601-encoded date"

    # @param value
    # @return [String]
    def self.coerce_result(value, _ctx)
      date = value.respond_to?(:to_date) ? value.to_date : value
      date.iso8601
    end

    # @param str_value [String]
    # @return [Date]
    def self.coerce_input(str_value, _ctx)
      str_value.respond_to?(:to_date) ? str_value.to_date : nil
    rescue ArgumentError
      # Invalid input
      nil
    end
  end
end
