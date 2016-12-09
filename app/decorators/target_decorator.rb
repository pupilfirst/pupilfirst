class TargetDecorator < Draper::Decorator
  delegate_all

  def status_badge_class(founder)
    status(founder).to_s.split('_').join('-')
  end

  def status_text(founder)
    I18n.t("target.status.#{status(founder)}")
  end
end
