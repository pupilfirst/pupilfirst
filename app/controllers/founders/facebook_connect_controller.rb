module Founders
  class FacebookConnectController < ApplicationController
    before_action :authenticate_founder!
    before_action :require_active_subscription

    def connect
      facebook_client = Founders::FacebookService.new(current_founder)
      redirect_to facebook_client.oauth_url
    end

    # TODO: Probably refactor
    def connect_callback
      if params[:error].present?
        flash[:error] = 'Something went wrong while connecting to Facebook. Please try again!'
      elsif params[:code].present?
        facebook_client = Founders::FacebookService.new(current_founder)
        token, expires = facebook_client.get_access_token_info(params[:code])
        if facebook_client.permissions_granted?(token)
          facebook_client.save_facebook_info!(token, expires)
          flash[:success] = 'Facebook Connection Successful!'
        else
          flash[:error] = 'Publish rights are required. Please try again!'
        end
      else
        raise 'Unexpected Facebook Response'
      end

      redirect_to edit_founder_path
    end

    def disconnect
      Founders::FacebookService.new(current_founder).disconnect!
      flash[:success] = 'Facebook disconnected successfully!'
      redirect_to edit_founder_path
    end
  end
end
