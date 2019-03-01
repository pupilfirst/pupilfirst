module Schools
  module Quizzes
    class CreateForm < Reform::Form
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :target_id, validates: { presence: true }
      def save
        sync
        model.save!
      end
    end
  end
end
