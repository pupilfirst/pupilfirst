module Schools
  module Levels
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :unlock_on

      def save
        level.name = name
        level.unlock_on = unlock_on
        level.save!

        level
      end

      private

      def level
        @level ||= Level.find_by(id: id)
      end
    end
  end
end
