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
    # The split retrieval of targets is so that founder targets appear above team targets.
    pending_targets = @startup.targets.pending
    split_pending_targets = pending_targets.founder + pending_targets.not_target_roles

    # If any of the pending targets are completed for a viewer, show that separately.
    split_pending_targets = split_pending_targets.select do |target|
      !target.done_for_viewer?(current_founder)
    end

    # TODO: Probably rewrite the target partial as 'pending' and 'done' flags are no longer required
    [
      [split_pending_targets, { pending: true, done: false }]
    ]
  end

  # Only show expired targets that haven't been completed by founder already.
  def expired_targets
    expired_targets = @startup.targets.expired

    expired_targets.select do |target|
      !target.done_for_viewer?(current_founder)
    end
  end

  # Only show completed targets which were completed by the founder
  def completed_targets
    completed_targets = @startup.targets.completed

    completed_targets.select do |target|
      target.done_for_viewer?(current_founder)
    end
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
