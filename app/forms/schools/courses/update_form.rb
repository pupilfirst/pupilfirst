module Schools
  module Courses
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }

      def save
        sync
        model.save!
      end
    end
  end
end
