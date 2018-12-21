module Founders
  class ProfilePresenter < ApplicationPresenter
    def initialize(founder)
      @founder = founder
      super(view_context)
    end

    def timeline_events_for_display(viewer)
      events_for_display = timeline_events

      # Only display verified of needs-improvement events if 'viewer' is not a member of this startup.
      if viewer&.startup != self
        events_for_display = events_for_display.verified_or_needs_improvement
      end

      decorated_events = events_for_display.includes(:target, :timeline_event_files).order(:event_on, :updated_at).reverse_order

      # Hide founder events from everyone other than author of event.
      decorated_events.reject { |event| event.hidden_from?(viewer) }
    end
  end
end
