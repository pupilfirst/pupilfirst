class CreateWebPushSubscriptionMutator < ApplicationQuery
  property :endpoint, validates: { presence: true }
  property :p256dh, validates: { presence: true }
  property :auth, validates: { presence: true }

  def create_subscription
    current_user.update!(webpush_subscription: webpush_subscription)
  end

  private

  def webpush_subscription
    {
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth
    }
  end

  def authorized?
    current_user.present?
  end
end
