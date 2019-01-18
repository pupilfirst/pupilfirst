module Schools
  module Resources
    class CreateForm < Reform::Form
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :description, validates: { presence: true }
      property :link, validates: { presence: true }

      def save
        sync
        model.save!
      end
    end
  end
end
