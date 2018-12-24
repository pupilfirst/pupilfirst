module Founders
  class ProfilePresenter < ApplicationPresenter
    def initialize(founder)
      @founder = founder
    end

    def timeline_events_for_display(timeline_events, viewer)
      events_for_display = timeline_events

      # Only display verified of needs-improvement events if 'viewer' is not a member of this startup.
      if viewer != @founder
        events_for_display = events_for_display.verified_or_needs_improvement
      end

      events_for_display = events_for_display.includes(:target, :timeline_event_files).order(:event_on, :updated_at).reverse_order

      # Hide founder events from everyone other than author of event.
      events_for_display.reject { |event| event.hidden_from?(viewer) }
    end

    def detailed_description(event)
      "After #{target_prefix(event.target)} <em>#{event.target.title}:</em>\n #{event.description}"
    end

    private

    def target_prefix(target)
      case target.target_action_type
        when Target::TYPE_TODO
          'executing'
        when Target::TYPE_ATTEND
          'attending'
        when Target::TYPE_LEARN
          'watching'
        when Target::TYPE_READ
          'reading'
      end
    end
  end
end
