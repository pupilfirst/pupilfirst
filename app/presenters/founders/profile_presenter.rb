module Founders
  class ProfilePresenter < ApplicationPresenter
    def initialize(event)
      @event = event
    end

    def detailed_description
      "After #{target_prefix(@event.target)} <em>#{@event.target.title}:</em>\n #{@event.description}"
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
