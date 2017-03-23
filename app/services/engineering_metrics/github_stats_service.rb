module EngineeringMetrics
  class GithubStatsService
    def initialize
      @token = ENV.fetch('GITHUB_ACCESS_TOKEN')
    end

    def contributions
      contributions = fetch('repos/SVdotCO/sv.co/stats/contributors')
      contributions.reject! { |c| !c['author']['login'].in?(AUTHORS) }
      contributions.map { |c| pretty_contribution(c) }
    end

    AUTHORS = %w(harigopal ajaleelp mahesh-sv vinutv).freeze

    private

    def fetch(path)
      url = 'https://api.github.com/' + path
      JSON.parse(RestClient.get(url, Authorization: "token #{@token}"))
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
