module Schools
  module Resources
    class CreateForm < Reform::Form
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :link
      property :file

      def save(school_id)
        resource = Resource.new(title: title, description: title, school_id: school_id)
        link.present? ? resource.link = link : resource.file = file
        resource.save!
        resource
      end
    end
  end
end
