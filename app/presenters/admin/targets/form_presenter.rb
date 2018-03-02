module Admin
  module Targets
    class FormPresenter < ApplicationPresenter
      def initialize(target)
        @target = target
      end

      def valid_prerequisites
        return all_live_targets if !@target.persisted? || level.blank?

        all_live_targets.where.not(id: @target.id).joins(target_group: :level).where(level: level)
      end

      def error_class
        @target.errors[:description].present? ? 'error-replica' : ''
      end

      private

      def level
        @level ||= @target.target_group&.level
      end

      def all_live_targets
        @live_targets ||= Target.live
      end
    end
  end
end
