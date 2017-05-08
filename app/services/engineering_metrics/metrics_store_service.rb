module EngineeringMetrics
  class MetricsStoreService
    def initialize
      week_start = Time.zone.now.beginning_of_week
      @entry = EngineeringMetric.find_or_create_by(week_start_at: week_start)
    end

    def increment(metric)
      @entry.metrics[metric.to_s] = @entry.metrics[metric.to_s].to_i + 1
      @entry.save!
    end

    def decrement(metric)
      @entry.metrics[metric.to_s] = @entry.metrics[metric.to_s].to_i - 1
      @entry.save! unless @entry.metrics[metric.to_s].negative?
    end

    def record_code_coverage
      # contact Codecov API for latest coverage data
      token = Rails.application.secrets.codecov_access_token
      url = 'https://codecov.io/api/gh/SVdotCO/sv.co/branch/master?access_token=' + token
      response = JSON.parse(RestClient.get(url))
      coverage = response.dig('commit', 'totals', 'c').to_f

      # save the coverage in the week's EngineeringMetric
      @entry.metrics[:coverage] = coverage
      @entry.save!
    end
  end
end
