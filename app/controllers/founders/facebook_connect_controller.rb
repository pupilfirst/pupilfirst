module Founders
  class FacebookConnectController < ApplicationController
    before_action :authenticate_founder!

    def connect
      @facebook_client = Founders::FacebookService.new(current_founder)
      redirect_to @facebook_client.oauth_url
    end

    def connect_callback
      if params[:error].present? || permission_not_granted?
        set_flash_error
      elsif params[:code].present?
        set_access_token
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

    private

    def set_flash_error
      flash[:error] = "Something went wrong while connecting to Facebook (#{params[:error_description]}). Please try again!"
    end

    def set_access_token
      @facebook_client = Founders::FacebookService.new(current_founder)
      @facebook_client.save_access_token!(params[:code])
      flash[:success] = 'Facebook Connection Successful!'
    end

    # TODO
    def permission_not_granted?
      false
    end
  end
end
