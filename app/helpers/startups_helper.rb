module StartupsHelper
  def truncated_founder_name(name)
    truncate name, length: 20, separator: ' ', omission: ''
  end

  def needs_improvement_tooltip_text(event)
    if current_founder && @startup.founder?(current_founder)
      needs_improvement_tooltip_for_founder(event)
    else
      needs_improvement_tooltip_for_public(event)
    end
  end

  def needs_improvement_tooltip_for_founder(event)
    if event.improved_timeline_event.present?
      I18n.t('startups.show.timeline_cards.improved_later.tooltip_text.founder')
    else
      I18n.t('startups.show.timeline_cards.needs_improvement.tooltip_text.founder')
    end
  end

  def needs_improvement_tooltip_for_public(event)
    if event.improved_timeline_event.present?
      I18n.t('startups.show.timeline_cards.improved_later.tooltip_text.public')
    else
      I18n.t('startups.show.timeline_cards.needs_improvement.tooltip_text.public')
    end
  end

  def needs_improvement_status_text(event)
    if event.improved_timeline_event.present?
      I18n.t('startups.show.timeline_cards.improved_later.status_text')
    else
      I18n.t('startups.show.timeline_cards.needs_improvement.status_text')
    end
  end
end
