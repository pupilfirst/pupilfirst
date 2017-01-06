module Founders
  class FacebookService
    def initialize(founder)
      @founder = founder
      @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], redirect_url)
    end

    def oauth_url
      @oauth.url_for_oauth_code(permissions: 'publish_actions')
    end

    def update_access_token!(code)
      token_info = @oauth.get_access_token_info(code)
      @founder.update!(
        fb_access_token: token_info['access_token'],
        fb_token_expires_at: token_info['expires'].to_i.seconds.from_now
      )
    end

    private

    def redirect_url
      Rails.application.routes.url_helpers.facebook_connect_callback_founder_url
    end
  end
end
