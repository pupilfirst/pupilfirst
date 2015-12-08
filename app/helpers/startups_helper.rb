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
    truncated_name = truncate name, length: 20, separator: ' '

    if truncated_name != name
      link_to truncated_name, '#', 'data-toggle' => 'tooltip', 'data-placement' => 'top', title: name, class: 'truncated-founder-name'
    else
      name
    end
  end

  def targets_for_display
    # The split retrieval of targets is so that founder and team targets appear above others.
    pending_targets = @startup.targets.pending
    split_pending_targets = pending_targets.founder + pending_targets.not_target_roles

    completed_targets = @startup.targets.recently_completed
    split_completed_targets = completed_targets.founder + completed_targets.not_target_roles

    completed_by_viewer = []

    # If any of the pending targets are completed for a viewer, show that separately.
    split_pending_targets = split_pending_targets.select do |target|
      if target.done_for_viewer?(current_user)
        completed_by_viewer << target
        false
      else
        true
      end
    end

    [
      [split_pending_targets, { pending: true, done: false }],
      [completed_by_viewer, { pending: false, done: true }],
      [split_completed_targets, { pending: false, done: true }]
    ]
  end

  # Only show expired targets that haven't been completed by user already.
  def expired_targets
    expired_targets = @startup.targets.expired

    expired_targets.select do |target|
      !target.done_for_viewer?(current_user)
    end
  end

  def showcase_events_for_batch(batch)
    processed_startups = []
    showcase_events_startups = []

    batch.startups.approved
      .joins(:timeline_events).merge(TimelineEvent.verified.has_image)
      .order('timeline_events.event_on ASC').each do |startup|
      next if processed_startups.include? startup.id
      showcase_events_startups << [startup.showcase_timeline_event, startup]
      processed_startups << startup.id
    end

    showcase_events_startups
  end
end
