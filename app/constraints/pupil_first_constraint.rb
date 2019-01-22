class PupilFirstConstraint
  def matches?(request)
    # Match constraint if testing.
    return true if request.host.in? %w[127.0.0.1 www.example.com]

    # Match constraint if visiting an 'PupilFirst domain'.
    request.host.in? %w[pupilfirst.localhost www.pupilfirst.localhost pupilfirst.com www.pupilfirst.com]
  end
end
