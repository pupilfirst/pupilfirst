module StartupsHelper
  def registration_type_options(current_registration_type)
    list = Startup.valid_registration_types.map do |registration_type|
      [t("models.startup.registration_type.#{registration_type}"), registration_type]
    end

    options_for_select(list, current_registration_type)
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
