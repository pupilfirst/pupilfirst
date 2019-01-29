class DevelopmentConstraint
  def matches?(_request)
    # Match constraint if in the development environment.
    Rails.env.development?
  end
end
