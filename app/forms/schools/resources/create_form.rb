module Schools
  module Resources
    class CreateForm < Reform::Form
      property :title, validates: { presence: true, length: { maximum: 250 } }
      # property :description
      property :link
      property :file

      def save
        resource = Resource.new(title: title, description: title)
        link.present? ? resource.link = link : resource.file = file
        resource.save!
        resource
      end
    end
  end
end
