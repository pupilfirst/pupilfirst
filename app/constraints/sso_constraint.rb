class SsoConstraint
  def matches?(request)
    # Match constraint if testing.
    return true if request.host.in? %w[127.0.0.1 www.example.com]

    # Match constraint if visiting an 'Pupilfirst domain'.
    request.host == Rails.application.secrets.sso_domain
  end
end
