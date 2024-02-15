class SsoConstraint
  def matches?(request)
    return true unless Rails.application.credentials.multitenancy

    sso_domain = Rails.application.credentials.sso_domain

    return true if sso_domain.blank?

    # Match constraint if visiting the SSO domain.
    request.host == sso_domain
  end
end
