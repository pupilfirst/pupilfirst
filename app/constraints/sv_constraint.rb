class SvConstraint
  def matches?(request)
    # Match constraint if testing.
    return true if request.host.in? %w[127.0.0.1 www.example.com]

    # Match constraint if visiting an 'SV domain'.
    request.host.in? %w[sv.localhost www.sv.localhost sv.co www.sv.co]
  end
end
