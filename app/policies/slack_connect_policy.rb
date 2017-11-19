class SlackConnectPolicy < ApplicationPolicy
  def connect?
    user&.founder&.subscription_active?
  end

  def callback?
    connect?
  end

  def disconnect?
    user&.founder&.subscription_active? && user.founder.slack_access_token.present?
  end
end
