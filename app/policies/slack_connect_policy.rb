class SlackConnectPolicy < ApplicationPolicy
  def connect?
    current_founder.present?
  end

  def callback?
    connect?
  end

  def disconnect?
    current_founder.slack_access_token.present?
  end
end
