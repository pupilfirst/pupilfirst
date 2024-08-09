class DomainConstraint
  def initialize(domain_key)
    @domain_key = domain_key
  end

  def matches?(request)
    return true unless Settings.multitenancy

    domain = Settings.public_send(:"#{@domain_key}_domain")

    return true if domain.blank?

    # Match constraint if visiting the domain
    request.host == domain
  end
end
