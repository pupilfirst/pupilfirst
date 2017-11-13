class SendInBlueController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :unsubscribe_webhook

  def unsubscribe_webhook
    # A safety check to ensure we are in-fact handling unsubscriptions.
    raise "Unexpected event '#{params['event']}' received from SendInBlue" unless params['event'] == 'unsubscribed'

    email = params.fetch('email')
    Intercom::UnsubscribeJob.perform_later(email)

    head :ok
  end
end
