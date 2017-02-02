class TimelineEventDecorator < Draper::Decorator
  delegate_all

  def detailed_description
    target.present? ? description_with_target_prefix : description
  end

  private

  def description_with_target_prefix
    "<em>After #{target_prefix} '#{target.title}':</em>\n #{description}"
  end

  def target_prefix
    case target.target_type
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
