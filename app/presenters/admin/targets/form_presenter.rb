module Admin
  module Targets
    class FormPresenter < ApplicationPresenter
      def initialize(target)
        @target = target
        super
      end

      def valid_prerequisites
        return all_live_targets if !@target.persisted? || level.blank?

        all_live_targets.where.not(id: @target.id).where(target_groups: { level: level })
      end

      def error_class
        @target.errors[:description].present? ? 'error-replica' : ''
      end

      private

      def level
        @level ||= @target.target_group&.level
      end

      def all_live_targets
        Target.live.includes(:level, :course)
      end
    end
  end
end
