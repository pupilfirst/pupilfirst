class PupilFirstConstraint
  def matches?(request)
    # Match constraint if testing.
    return true if request.host.in? %w[127.0.0.1 www.example.com]

    # Match constraint if visiting an 'PupilFirst domain'.
    request.host.in?(Rails.application.secrets.pupilfirst_domains)
  end
end
