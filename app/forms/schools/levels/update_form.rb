module Schools
  module Levels
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :unlock_at

      def save
        level.name = name
        level.unlock_at = unlock_at_time
        level.save!

        level
      end

      private

      def unlock_at_time
        return if unlock_at.blank?

        Time.zone.parse(unlock_at)
      end

      def level
        @level ||= Level.find_by(id: id)
      end
    end
  end
end
