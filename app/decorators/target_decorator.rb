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
      when Target::STATUS_COMPLETE
        'fa-thumbs-o-up'
      when Target::STATUS_NEEDS_IMPROVEMENT
        'fa-line-chart'
      when Target::STATUS_NOT_ACCEPTED
        'fa-thumbs-o-down'
      when Target::STATUS_UNAVAILABLE
        'fa-lock'
      when Target::STATUS_SUBMITTED
        'fa-hourglass-half'
      when Target::STATUS_PENDING
        'fa-clock-o'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def completed_by?(founder)
    status(founder).in? [Target::STATUS_COMPLETE, Target::STATUS_NEEDS_IMPROVEMENT]
  end

  def pending_for?(founder)
    status(founder) == Target::STATUS_PENDING
  end

  def submittable?(founder)
    status(founder).in? [Target::STATUS_PENDING, Target::STATUS_NEEDS_IMPROVEMENT, Target::STATUS_NOT_ACCEPTED, Target::STATUS_COMPLETE]
  end

  def re_submittable?(founder)
    status(founder).in? [Target::STATUS_NEEDS_IMPROVEMENT, Target::STATUS_NOT_ACCEPTED, Target::STATUS_COMPLETE]
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
