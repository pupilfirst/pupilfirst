class RateLimitValidator < ActiveModel::Validator
  cattr_accessor :migration_running

  def validate(record)
    unless migration_running?
      limit = options[:limit]
      scope = options[:scope]
      time_frame = options[:time_frame]

      if limit.nil? || scope.nil?
        raise ArgumentError,
              "Mandatory options :limit and :scope must be provided"
      end

      query = record.class.where(scope => record.send(scope))
      query =
        query.where("created_at >= ?", Time.now - time_frame) if time_frame
      count = query.count

      if count >= limit
        record.errors.add(:base, "Rate limit exceeded: #{limit}")
      end
    end
  end

  def migration_running?
    self.migration_running
  end
end
