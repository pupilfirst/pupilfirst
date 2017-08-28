class TargetDecorator < Draper::Decorator
  delegate_all

  def status_badge_class(founder)
    status(founder).to_s.split('_').join('-')
  end

  def status_text(founder)
    I18n.t("target.status.#{status(founder)}")
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def status_fa_icon(founder)
    case status(founder)
      when Targets::StatusService::STATUS_COMPLETE
        'fa-thumbs-o-up'
      when Targets::StatusService::STATUS_NEEDS_IMPROVEMENT
        'fa-line-chart'
      when Targets::StatusService::STATUS_NOT_ACCEPTED
        'fa-thumbs-o-down'
      when Targets::StatusService::STATUS_UNAVAILABLE
        'fa-lock'
      when Targets::StatusService::STATUS_SUBMITTED
        'fa-hourglass-half'
      when Targets::StatusService::STATUS_PENDING
        'fa-clock-o'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def completed_by?(founder)
    status(founder).in? [Targets::StatusService::STATUS_COMPLETE, Targets::StatusService::STATUS_NEEDS_IMPROVEMENT]
  end

  def pending_for?(founder)
    status(founder) == Targets::StatusService::STATUS_PENDING
  end

  def submittable?(founder)
    status(founder).in? [Targets::StatusService::STATUS_PENDING, Targets::StatusService::STATUS_NEEDS_IMPROVEMENT, Targets::StatusService::STATUS_NOT_ACCEPTED, Targets::StatusService::STATUS_COMPLETE]
  end

  def re_submittable?(founder)
    status(founder).in? [Targets::StatusService::STATUS_NEEDS_IMPROVEMENT, Targets::StatusService::STATUS_NOT_ACCEPTED, Targets::StatusService::STATUS_COMPLETE]
  end

  def submit_button_fa_icon(founder)
    re_submittable?(founder) ? 'fa-repeat' : 'fa-upload'
  end

  def submit_button_text(founder)
    re_submittable?(founder) ? 'Re-Submit' : 'Submit'
  end

  def team_or_personal
    founder_role? ? 'Personal' : 'Team'
  end
end
