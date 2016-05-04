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

  def stage_link(stage)
    text = TimelineEventType::STAGE_NAMES[stage]
    link = TimelineEventType::STAGE_LINKS[stage]

    link_to link, target: '_blank' do
      "#{text} <i class='fa fa-external-link'></i>".html_safe
    end
  end

  def truncated_founder_name(name)
    truncate name, length: 20, separator: ' ', omission: ''
  end

  def pending_targets
    current_founder.targets.pending.order(due_date: 'desc') + @startup.targets.pending.order(due_date: 'desc')
  end

  # Only show expired targets that haven't been completed by founder already.
  def expired_targets
    current_founder.targets.expired.order(due_date: 'desc') + @startup.targets.expired.order(due_date: 'desc')
  end

  # Only show completed targets which were completed by the founder
  def completed_targets
    current_founder.targets.completed.order(completed_at: 'desc') + @startup.targets.completed.order(completed_at: 'desc')
  end

  def showcase_events_for_batch(batch)
    processed_startups = []
    showcase_events_startups = []

    batch.startups.approved
      .joins(:timeline_events).merge(TimelineEvent.verified)
      .order('timeline_events.event_on ASC').each do |startup|
      next if processed_startups.include? startup.id
      showcase_events_startups << [startup.showcase_timeline_event, startup]
      processed_startups << startup.id
    end

    showcase_events_startups
  end

  def extra_links_present?(startup)
    startup.website.present? ||
      startup.wireframe_link.present? ||
      startup.prototype_link.present? ||
      startup.facebook_link.present? ||
      startup.twitter_link.present?
  end
end
