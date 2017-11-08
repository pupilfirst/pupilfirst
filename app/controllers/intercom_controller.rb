class IntercomController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :user_create

  # POST /intercom/user_create
  #
  # End-point to receive user.created webhooks.
  def user_create_webhook
    raise 'Unexpected Intercom Webhook Topic' unless params[:topic] == 'user.created'

    email = params.dig(:data, :item, :email)
    raise 'Could not retrieve email from Webhook POST' if email.blank?

    IntercomClient.new.strip_user_id(email)
    head :ok
  end

  # POST /intercom/email_unsubscribe
  #
  # End-point to receive unsubscribe webhooks.
  def email_unsubscribe_webhook
    raise 'Unexpected Intercom Webhook Topic' unless params[:topic] == 'user.unsubscribed'

    _email = params.dig(:data, :item, :email)
    # TODO: Inform SendInBlue to mark this email as unsubscribed.

    head :ok
  end
end
