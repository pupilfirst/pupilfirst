module Startups
  class FilterForm < Reform::Form
    property :level_id, allow_blank: true
    property :startup_category_id, allow_blank: true
    property :search, allow_blank: true
    property :page

    # Custom Validations
    validate :page_number_should_be_valid
    validate :level_should_be_valid
    validate :category_should_be_valid

    def category_should_be_valid
      return if startup_category_id.blank?
      return if StartupCategory.find_by(id: startup_category_id).present?
      errors[:base] << 'Invalid category supplied.'
    end

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
