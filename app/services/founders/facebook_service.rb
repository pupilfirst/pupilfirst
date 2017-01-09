module Founders
  class FacebookService
    def initialize(founder)
      @founder = founder
    end

    def oauth_url
      oauth.url_for_oauth_code(permissions: 'publish_actions')
    end

    def get_access_token_info(code)
      token_info = oauth.get_access_token_info(code)
      [token_info['access_token'], token_info['expires'].to_i.seconds.from_now]
    end

    def save_token_info!(token, expires)
      @founder.update!(fb_access_token: token, fb_token_expires_at: expires)
    end

    def basic_info
      raise 'UnAuthorized Founder' unless @founder.facebook_connected?

      result = api(@founder.fb_access_token).get_object(:me, fields: [:name, :picture, :link])
      {
        name: result['name'],
        picture_url: result.dig('picture', 'data', 'url'),
        link: result['link']
      }
    end

    def disconnect!
      @founder.update!(fb_access_token: nil, fb_token_expires_at: nil)
    end

    def permissions_granted?(token)
      permissions = api(token).get_object(:me, fields: :permissions).dig('permissions', 'data')
      publish_permission = permissions.detect { |p| p['permission'] == 'publish_actions' }

      publish_permission && publish_permission['status'] == 'granted'
    end

    private

    def oauth
      @oauth ||= Koala::Facebook::OAuth.new(ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], redirect_url)
    end

    def api(token)
      Koala::Facebook::API.new(token)
    end

    def redirect_url
      Rails.application.routes.url_helpers.founder_facebook_connect_callback_url
    end
  end
end
