module Startups
  class FilterForm < Reform::Form
    property :level_id, allow_blank: true
    property :search, allow_blank: true
    property :page

    # Custom Validations
    validate :page_number_should_be_valid
    validate :level_should_be_valid

    def page_number_should_be_valid
      return if page.blank?
      return if page.to_i.to_s == page

      errors[:base] << 'Not a valid page number.'
    end

    def level_should_be_valid
      return if level_id.blank?
      return if Level.find_by(id: level_id).present?

      errors[:base] << 'Invalid level supplied.'
    end
  end
end
