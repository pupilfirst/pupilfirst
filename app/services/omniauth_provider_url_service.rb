class OmniauthProviderUrlService
  include RoutesResolvable

  def initialize(provider, host)
    @provider = provider
    @host = host
  end

  def oauth_url
    url_opts = { host: @host }

    case @provider.to_s
      when 'developer'
        url_helpers.user_developer_omniauth_authorize_url(url_opts)
      when 'google'
        url_helpers.user_google_oauth2_omniauth_authorize_url(url_opts)
      when 'facebook'
        url_helpers.user_facebook_omniauth_authorize_url(url_opts)
      when 'github'
        url_helpers.user_github_omniauth_authorize_url(url_opts)
      else
        raise "Invalid provider #{@provider} supplied to oauth redirection route."
    end
  end
end
