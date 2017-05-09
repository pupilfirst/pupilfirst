module ActiveAdmin
  class EngineeringMetricsDashboardPresenter
    def codecov_badge_url
      token = Rails.application.secrets.codecov_graphing_token
      return if token.blank?
      'https://codecov.io/gh/SVdotCO/sv.co/branch/master/graphs/badge.svg?token=' + token
    end

    def commit_trend
      counts = last_week_metrics.dig('github', 'commits_trend') || []

      counts.map do |author, commits|
        {
          name: author,
          data: commits.each_with_object({}).with_index do |(count, trend), index|
            trend[(index + 1).weeks.ago.beginning_of_week] = count
          end
        }
      end
    end

    def code_frequency
      trend = [
        { name: 'Addition', data: {} },
        { name: 'Deletion', data: {} }
      ]

      counts = last_week_metrics.dig('github', 'code_frequency') || []

      counts.map do |time, additions, deletions|
        trend[0][:data][Time.at(time)] = additions
        trend[1][:data][Time.at(time)] = -deletions
      end

      trend
    end

    def bugs_trend
      last_10_metrics.reverse.each_with_object({}) do |metric, trend|
        trend[metric[1]] = metric[0].dig('bugs') || 0
      end
    end

    def deploys_trend
      last_10_metrics.reverse.each_with_object({}) do |metric, trend|
        trend[metric[1]] = metric[0].dig('deploys') || 0
      end
    end

    def language_trend
      languages = last_week_metrics['loc']&.keys || []

      languages.map do |language|
        {
          name: language,
          data: last_10_metrics.reverse.each_with_object({}) do |(metrics, week_start_at), result|
            result[week_start_at] = metrics.dig('loc', language)
          end
        }
      end
    end

    private

    def last_week_metrics
      @last_week_metrics ||= (EngineeringMetric.find_by(week_start_at: 7.days.ago.beginning_of_week)&.metrics || {})
    end

    def last_10_metrics
      @last_10_metrics ||= EngineeringMetric.order('week_start_at DESC').limit(10).pluck(:metrics, :week_start_at)
    end
  end
end
