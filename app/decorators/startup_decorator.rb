class StartupDecorator < Draper::Decorator
  delegate_all

  def identicon_logo
    base64_logo = Startups::IdenticonLogoService.new(model).base64_svg
    h.image_tag("data:image/svg+xml;base64,#{base64_logo}", class: 'startup-logo')
  end

  def completed_targets_count
    timeline_events.verified_or_needs_improvement.where.not(target_id: nil).distinct.count(:target_id)
  end

  def completed_targets_percentage
    ((completed_targets_count.to_f / batch.targets.count) * 100).to_i
  end
end
