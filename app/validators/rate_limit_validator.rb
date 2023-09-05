class RateLimitValidator < ActiveModel::Validator
  def validate(record)
    limit = options[:limit]
    scope = options[:scope]
    time_frame = options[:time_frame]

    if limit.nil? || scope.nil?
      raise ArgumentError,
            "Mandatory options :limit and :scope must be provided"
    end

    query = record.class.where(scope => record.send(scope))
    query = query.where("created_at >= ?", Time.now - time_frame) if time_frame
    count = query.count

    record.errors.add(:base, "Rate limit exceeded: #{limit}") if count >= limit
  end
end
