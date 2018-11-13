class TimelineEventDecorator < Draper::Decorator
  delegate_all

  def detailed_description
    "After #{target_prefix} <em>#{target.title}:</em>\n #{description}"
  end

  private

  def target_prefix
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
