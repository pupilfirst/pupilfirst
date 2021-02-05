class DeleteWebPushSubscriptionMutator < ApplicationQuery
  def delete_subscription
    current_user.update!(webpush_subscription: {})
  end

  private

  def authorized?
    current_user.present?
  end
end

