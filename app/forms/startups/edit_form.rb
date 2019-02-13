module Startups
  class EditForm < Reform::Form
    property :product_name, validates: { presence: true }
    property :legal_registered_name
    property :logo, validates: { file_size: { less_than: 2.megabytes }, file_content_type: { allow: %w[image/jpeg image/png image/gif] }, raster_image: true }
    property :slug

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
