module StartupsHelper
  def registration_type_html(registration_type)
    case registration_type
      when Startup::REGISTRATION_TYPE_PARTNERSHIP
        'Partnership'
      when Startup::REGISTRATION_TYPE_PRIVATE_LIMITED
        'Private Limited'
      when Startup::REGISTRATION_TYPE_LLP
        'Limited Liability Partnership'
      else
        '<em>Not Registered</em>'.html_safe
    end
  end

  def truncated_founder_name(name)
    truncate name, length: 20, separator: ' ', omission: ''
  end

  def extra_links_present?(startup)
    startup.website.present? ||
      startup.wireframe_link.present? ||
      startup.prototype_link.present? ||
      startup.facebook_link.present? ||
      startup.twitter_link.present?
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
      I18n.t('startup.show.timeline_cards.improved_later.tooltip_text.founder')
    else
      I18n.t('startup.show.timeline_cards.needs_imprvement.tooltip_text.founder')
    end
  end

  def needs_improvement_tooltip_for_public(event)
    if event.improved_timeline_event.present?
      I18n.t('startup.show.timeline_cards.improved_later.tooltip_text.public')
    else
      I18n.t('startup.show.timeline_cards.needs_imprvement.tooltip_text.public')
    end
  end

  def needs_improvement_status_text(event)
    if event.improved_timeline_event.present?
      I18n.t('startup.show.timeline_cards.improved_later.status_text')
    else
      I18n.t('startup.show.timeline_cards.needs_imprvement.status_text')
    end
  end
end
