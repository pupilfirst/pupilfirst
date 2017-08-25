module Founders
  class SlackConnectController < ApplicationController
    before_action :authenticate_founder!

    # POST /founders/slack/invite
    #
    # Send invitation to join Slack to founder.
    def invite
      current_founder
    end

    # GET /founders/slack/connect
    def connect
      slack_connect_service = Founders::SlackConnectService.new(current_founder)
      observable_redirect_to(slack_connect_service.redirect_url)
    end

    # GET /founders/slack/callback
    def callback
      slack_connect_service = Founders::SlackConnectService.new(current_founder)

      if params[:code].present?
        begin
          slack_connect_service.connect(params[:code])

          # TODO: Update username on Slack if connect was successful.

          flash[:success] = 'Your Slack account has been connected successfully!'
          # rescue # TODO: rescue specific errors
          #   raise 'Unexpected Slack Response'
        end
      else
        flash[:error] = 'Did not received authorization from Slack.'
      end

      redirect_to edit_founder_path
    end

    # POST /founders/slack/disconnect
    def disconnect
      slack_connect_service = Founders::SlackConnectService.new(current_founder)
      slack_connect_service.disconnect
      flash[:success] = 'Your SV.CO account has been disconnected from your Slack account.'
      redirect_to edit_founder_path
    end
  end
end
