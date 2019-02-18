module Schools
  module Levels
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :number, validates: { format: { with: /\A\d+\z/, message: "Not a valid number" } }
      property :unlock_on

      validate :level_number_exists

      def save
        level.update!(name: name, number: number)
        level.update!(unlock_on: unlock_on) if unlock_on.present?
        level
      end

      private

      def level
        @level ||= Level.find_by(id: id)
      end

      def level_number_exists
        return if level.course.levels.blank?

        return if level.number == number.to_i

        errors[:base] << 'Level number exists' if level.course.levels.where(number: number).present?
      end
    end
  end
end
