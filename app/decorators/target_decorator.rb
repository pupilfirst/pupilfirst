class TargetDecorator < Draper::Decorator
  delegate_all

  def status_badge_class(founder)
    status(founder).to_s.split('_').join('-')
  end

  def status_text(founder)
    I18n.t("target.status.#{status(founder)}")
  end

  ATTEND_SESSION_ICON = 'attend_session_icon.svg'.freeze
  TEAM_TODO_ICON = 'team_todo_icon.svg'.freeze
  PERSONAL_TODO_ICON = 'personal_todo_icon.svg'.freeze
  LEARN_ICON = 'read_icon.svg'.freeze

  def type_icon_name
    case target_type
      when Target::TYPE_READ
        READ_ICON
      when Target::TYPE_LEARN
        LEARN_ICON
      when Target::TYPE_ATTEND
        ATTEND_SESSION_ICON
      when Target::TYPE_TODO
        founder? ? PERSONAL_TODO_ICON : TEAM_TODO_ICON
      else
        TEAM_TODO_ICON
    end
  end

  def completed_by?(founder)
    status(founder).in? [Targets::StatusService::STATUS_COMPLETE, Targets::StatusService::STATUS_NEEDS_IMPROVEMENT]
  end
end
