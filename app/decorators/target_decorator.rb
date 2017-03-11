class TargetDecorator < Draper::Decorator
  delegate_all

  def status_badge_class(founder)
    status(founder).to_s.split('_').join('-')
  end

  def status_text(founder)
    I18n.t("target.status.#{status(founder)}")
  end

  def status_report_text(founder)
    I18n.t("target.status_report.#{status(founder)}")
  end

  def status_hint_text(founder)
    I18n.t("target.status_hint.#{status(founder)}", date: timeline_events&.last&.event_on&.strftime('%b %e'))
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def status_fa_icon(founder)
    case status(founder)
      when Targets::StatusService::STATUS_COMPLETE
        'fa-thumbs-o-up'
      when Targets::StatusService::STATUS_NEEDS_IMPROVEMENT
        'fa-line-chart'
      when Targets::StatusService::STATUS_EXPIRED
        'fa-hourglass-end'
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

  ATTEND_SESSION_ICON = 'attend_session_icon.svg'.freeze
  TEAM_TODO_ICON = 'team_todo_icon.svg'.freeze
  PERSONAL_TODO_ICON = 'personal_todo_icon.svg'.freeze
  LEARN_ICON = 'read_icon.svg'.freeze
  READ_ICON = 'read_icon.svg'.freeze

  def type_icon_name
    case target_type
      when Target::TYPE_READ
        READ_ICON
      when Target::TYPE_LEARN
        LEARN_ICON
      when Target::TYPE_ATTEND
        ATTEND_SESSION_ICON
      when Target::TYPE_TODO
        founder_role? ? PERSONAL_TODO_ICON : TEAM_TODO_ICON
      else
        TEAM_TODO_ICON
    end
  end

  def completed_by?(founder)
    status(founder).in? [Targets::StatusService::STATUS_COMPLETE, Targets::StatusService::STATUS_NEEDS_IMPROVEMENT]
  end

  def pending_for?(founder)
    status(founder) == Targets::StatusService::STATUS_PENDING
  end

  def submittable?(founder)
    status(founder).in? [Targets::StatusService::STATUS_PENDING, Targets::StatusService::STATUS_NEEDS_IMPROVEMENT, Targets::StatusService::STATUS_NOT_ACCEPTED, Targets::StatusService::STATUS_EXPIRED, Targets::StatusService::STATUS_COMPLETE]
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

  def self.fa_icon_for_filter(filter)
    { Founders::TargetsFilterService::EXPIRES_IN_A_WEEK => 'fa-clock-o',
      Founders::TargetsFilterService::EXPIRED => 'fa-hourglass-end',
      Founders::TargetsFilterService::NOT_ACCEPTED => 'fa-thumbs-o-down',
      Founders::TargetsFilterService::NEEDS_IMPROVEMENT => 'fa-line-chart',
      Founders::TargetsFilterService::ALL_TARGETS => 'fa-list-ul' }[filter]
  end
end
