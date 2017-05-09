module EngineeringMetrics
  class MetricsStoreService
    def execute
      record_code_coverage
    end

    def increment(metric)
      current_entry.metrics[metric.to_s] = current_entry.metrics[metric.to_s].to_i + 1
      current_entry.tap(&:save!)
    end

    def decrement(metric)
      return current_entry if (current_entry.metrics[metric.to_s].to_i - 1).negative?
      current_entry.metrics[metric.to_s] = current_entry.metrics[metric.to_s].to_i - 1
      current_entry.tap(&:save!)
    end

    private

    def current_entry
      @current_entry ||= EngineeringMetric.where(week_start_at: Time.zone.now.beginning_of_week).first_or_create!
    end

    # Contact Codecov API for latest coverage data and store that for this week.
    def record_code_coverage
      token = Rails.application.secrets.codecov_access_token
      url = 'https://codecov.io/api/gh/SVdotCO/sv.co/branch/master?access_token=' + token
      response = JSON.parse(RestClient.get(url))
      coverage = response.dig('commit', 'totals', 'c').to_f

      # Save the retrieved coverage data.
      current_entry.metrics[:coverage] = coverage
      current_entry.save!
    end
  end
end
