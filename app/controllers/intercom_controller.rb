class IntercomController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[user_create_webhook email_unsubscribe_webhook]

  # POST /intercom/user_create
  #
  # End-point to receive user.created webhooks.
  def user_create_webhook
    raise "Unexpected Intercom Webhook Topic: #{params[:topic]}" unless params[:topic] == 'user.created'

    email = params.dig(:data, :item, :email)
    raise 'Could not retrieve email from Webhook POST' if email.blank?

    IntercomClient.new.strip_user_id(email)
    head :ok
  end

  # POST /intercom/email_unsubscribe
  #
  # End-point to receive unsubscribe webhooks.
  def email_unsubscribe_webhook
    raise "Unexpected Intercom Webhook Topic: #{params[:topic]}" unless params[:topic] == 'user.unsubscribed'

    email = params.dig(:data, :item, :email)
    raise 'Could not retrieve email from Webhook POST' if email.blank?

    SendInBlue::UnsubscribeJob.perform_later(email)
    head :ok
  end
end
