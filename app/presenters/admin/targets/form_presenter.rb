module Admin
  module Targets
    class FormPresenter < ApplicationPresenter
      def initialize(view_context, target)
        @target = target
        super(view_context)
      end

      def valid_prerequisites
        if !@target.persisted? || @target.level.blank?
          live_targets
        elsif @target.level.number.zero?
          live_targets.where.not(id: @target.id).joins(:level).where(level: Level.zero)
        else
          live_targets.where.not(id: @target.id).joins(:level).where.not(level: Level.zero).where('levels.number <= ?', @target.level.number)
        end
      end

      private

      def live_targets
        @live_targets ||= Target.live
      end
    end
  end
end
