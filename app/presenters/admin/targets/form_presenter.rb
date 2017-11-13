module Admin
  module Targets
    class FormPresenter < ApplicationPresenter
      def initialize(view_context, target)
        @target = target
        super(view_context)
      end

      def valid_prerequisites
        return live_targets if !@target.persisted? || (@target.level.blank? && @target.target_group&.level.blank?)

        if level.number.zero?
          live_targets.where.not(id: @target.id).joins(:level).where(level: Level.zero)
        else
          live_targets.where.not(id: @target.id).joins(:level).where.not(level: Level.zero).where('levels.number <= ?', level.number)
        end
      end

      private

      def level
        @level ||= @target.level || @target.target_group.level
      end

      def live_targets
        @live_targets ||= Target.live
      end
    end
  end
end
