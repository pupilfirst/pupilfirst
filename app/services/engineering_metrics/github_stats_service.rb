module EngineeringMetrics
  class GithubStatsService
    include Loggable

    AUTHORS = %w[harigopal ajaleelp mahesh-krishnakumar vinutv].freeze

    def initialize
      @token = Rails.application.secrets.github[:access_token]
    end

    # Get data from any Github API end-point.
    def get(path)
      url = 'https://api.github.com/' + path

      keep_trying = true
      response = nil

      while keep_trying
        log "Hitting Github URL: #{url}"
        response = RestClient.get(url, Authorization: "token #{@token}")

        if response.code == 202
          log 'Response from Github was a 202. Waiting for 10s before trying again.'
          sleep 10
        elsif response.code == 200
          keep_trying = false
        else
          raise "Unexpected response code #{code} received from Github."
        end
      end

      JSON.parse(response.body)
    end

    # Commits per founder per week for last 10 weeks.
    def commits_trend
      contributions.each_with_object({}) do |developer_stats, result|
        result[developer_stats[:name].to_sym] = developer_stats[:recent_weeks].map { |_k, a| a[:commits] }
      end
    end

    # Additions and deletions per week for last 10 weeks.
    def code_frequency
      get('repos/SVdotCO/sv.co/stats/code_frequency')[-10..-1]
    end

    private

    # Contribution details per founder per week - including additions, deletions and commits.
    def contributions
      contributions = get('repos/SVdotCO/sv.co/stats/contributors')
      contributions.select! { |c| c['author']['login'].in?(AUTHORS) }
      contributions.map { |c| pretty_contribution(c) }
    end

    def pretty_contribution(user_contribution)
      {
        name: user_contribution['author']['login'],
        total_commits: user_contribution['total'],
        recent_weeks: recent_activity(user_contribution['weeks'])
      }
    end

    def recent_activity(contribution)
      contribution[-10..-1].each_with_object({}) do |week, result|
        result[week['w']] = { additions: week['a'], deletions: week['d'], commits: week['c'] }
      end
    end
  end
end
