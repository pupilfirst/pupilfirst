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

    def loc
      last_loc = last_week_metrics.dig('loc')
      return [] if last_loc.blank?

      last_loc.to_a.map do |(language, stats)|
        [language, stats['code']]
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

    def language_trend
      languages = last_week_metrics['loc']&.keys || []

      languages.map do |language|
        {
          name: language,
          data: last_10_metrics.reverse.each_with_object({}) do |(metrics, week_start_at), result|
            result[week_start_at] = metrics.dig('loc', language, 'code')
          end
        }
      end
    end

    def trend(type)
      last_10_metrics.reverse.each_with_object({}) do |metric, trend|
        trend[metric[1]] = metric[0].dig(type.to_s) || 0
      end
    end

    def current_release
      release_verison = EngineeringMetric.order('week_start_at DESC').first.metrics['release_version']
      return release_verison if release_verison.present?
      last_week_metrics['release_version']
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
