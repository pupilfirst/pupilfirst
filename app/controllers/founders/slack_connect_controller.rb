module Founders
  class SlackConnectController < ApplicationController
    before_action :authenticate_founder!

    # GET /founders/slack/connect
    def connect
      authorize :slack_connect
      slack_connect_service = Founders::SlackConnectService.new(current_founder)
      observable_redirect_to(slack_connect_service.redirect_url)
    end

    # GET /founders/slack/callback
    def callback
      authorize :slack_connect

      slack_connect_service = Founders::SlackConnectService.new(current_founder)

      if params[:code].present?
        slack_connect_service.connect(params[:code])

        # Update their Slack profile name.
        Founders::UpdateSlackNameJob.perform_later(current_founder)

        # TODO: Invite them to all channels.

        flash[:success] = 'Your Slack account has been connected successfully!'
      else
        flash[:error] = 'Did not receive authorization from Slack.'
      end

      redirect_to edit_founder_path
    end

    # POST /founders/slack/disconnect
    def disconnect
      authorize :slack_connect

      slack_connect_service = Founders::SlackConnectService.new(current_founder)
      slack_connect_service.disconnect
      flash[:success] = 'Your SV.CO account has been disconnected from your Slack account.'
      redirect_to edit_founder_path
    end
  end
end
