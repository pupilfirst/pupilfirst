module Startups
  class EditForm < Reform::Form
    property :product_name, validates: { presence: true }
    property :product_description, validates: { length: { maximum: Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS } }
    property :presentation_link, validates: { url: true, allow_blank: true }
    property :legal_registered_name
    property :logo, validates: { file_size: { less_than: 2.megabytes }, file_content_type: { allow: %w[image/jpeg image/png image/gif] }, raster_image: true }
    property :startup_category_ids
    property :email, validates: { length: { maximum: 250 }, email: true }
    property :website, validates: { url: true, allow_blank: true }
    property :twitter_link, validates: { url: true, allow_blank: true }
    property :facebook_link, validates: { url: true, allow_blank: true }
    property :slug
    property :product_video_link, validates: { url: true, allow_blank: true }
    property :prototype_link, validates: { url: true, allow_blank: true }
    property :wireframe_link, validates: { url: true, allow_blank: true }
    property :registration_type, validates: { inclusion: { in: Startup.valid_registration_types }, allow_blank: true }

    # Custom validations.
    validate :startup_categories_must_be_valid

    def startup_categories_must_be_valid
      return if startup_category_ids.blank?
      self.startup_category_ids -= ['']

      startup_category_ids.each do |startup_category_id|
        next if StartupCategory.find(startup_category_id).present?
        errors.add(:startup_category_ids, 'contained unrecognized value')
      end
    end

    def save!
      product_name_changed = model.product_name != product_name

      sync
      model.save!

      # Update their profile name on Slack if the product name has changed.
      if product_name_changed
        model.founders.each { |founder| Founders::UpdateSlackNameJob.perform_later(founder) }
      end
    end
  end
end
