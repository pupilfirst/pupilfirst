class SlackConnectPolicy < ApplicationPolicy
  def connect?
    current_founder&.subscription_active?
  end

  def callback?
    connect?
  end

  def disconnect?
    current_founder&.subscription_active? && current_founder.slack_access_token.present?
  end
end
