module ActiveAdmin
  class EngineeringMetricsDashboardPresenter
    def codecov_badge_url
      token = Rails.application.secrets.codecov_graphing_token
      'https://codecov.io/gh/SVdotCO/sv.co/branch/master/graphs/badge.svg?token=' + token
    end

    delegate :commits_trend, to: :github_service

    def code_frequency
      github_service.code_frequency&.map { |w| "#{w[1]}:#{w[2]}" }&.join(', ')
    end

    def last_week_bugs
      last_week_metrics&.metrics&.dig('bugs') || 0
    end

    def bugs_trend
      last_10_metrics.reverse.map { |metric| metric.dig('bugs') || 0 }.join(', ')
    end

    def last_week_deploys
      last_week_metrics&.metrics&.dig('deploys') || 0
    end

    def deploys_trend
      last_10_metrics.reverse.map { |metric| metric.dig('deploys') || 0 }.join(', ')
    end

    private

    def github_service
      @github_service ||= EngineeringMetrics::GithubStatsService.new
    end

    def last_week_metrics
      @last_week_metrics ||= EngineeringMetric.find_by(week_start_at: 7.days.ago.beginning_of_week)
    end

    def last_10_metrics
      @last_10_metrics ||= EngineeringMetric.order('week_start_at DESC').limit(10).pluck(:metrics)
    end
  end
end
