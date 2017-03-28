module EngineeringMetrics
  class MetricsStoreService
    def initialize
      week_start = Time.zone.now.beginning_of_week.to_i
      @entry = EngineeringMetric.find_or_create_by(week_start: week_start)
    end

    def increment(metric)
      @entry.metrics[metric.to_s] = @entry.metrics[metric.to_s].to_i + 1
      @entry.save!
    end

    def decrement(metric)
      @entry.metrics[metric.to_s] = @entry.metrics[metric.to_s].to_i - 1
      @entry.save! unless @entry.metrics[metric.to_s].negative?
    end
  end
end
