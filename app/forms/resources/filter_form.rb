module Resources
  class FilterForm < Reform::Form
    property :tags, allow_blank: true
    property :search, allow_blank: true
    property :created_after, validates: { inclusion: { in: proc { |form| form.date_filter_options } }, allow_blank: true }
    property :page

    # Custom Validations
    validate :page_number_should_be_valid
    validate :tags_must_be_in_the_list

    def tags_must_be_in_the_list
      return if tags.blank?

      # Remove the blank value supplied in the form.
      self.tags -= ['']

      return if (tags - resource_tags).empty?
      errors[:base] << 'Invalid tag supplied.'
    end

    def page_number_should_be_valid
      return if page.blank?
      return if page.to_i.to_s == page
      errors[:base] << 'Not a valid page number.'
    end

    def date_filter_options
      ['Since Yesterday', 'Past Week', 'Past Month', 'Past Year']
    end

    def resource_tags
      Resource.tag_counts_on(:tags).pluck(:name)
    end
  end
end
