module EngineeringMetrics
  class MetricsStoreService
    include Loggable

    def execute
      log 'Recording code coverage...'
      record_code_coverage

      log 'Recording language split...'
      record_language_split

      log 'Recording Github stats...'
      record_github_stats
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

    # Use linguist to store programming-language
    def record_language_split
      require 'rugged'
      require 'linguist'

      prepare_repository
      repo = Rugged::Repository.new(Rails.root.to_s)
      project = Linguist::Repository.new(repo, repo.head.target_id)
      current_entry.metrics[:loc] = project.languages
      current_entry.save!
    end

    # This method creates a new Git repository in the root of the app. This is requires for Rugged::Repository
    # to work, which is in turn required by Linguist for
    def prepare_repository
      return unless Rails.env.production?
      root_path = Rails.root.to_s

      commands = <<~COMMANDS
        cd #{root_path}
        git init
        git config user.name "Vocalist"
        git config user.email "hosting@sv.co"

        echo ".apt/" >> .gitignore
        echo ".profile.d/" >> .gitignore
        echo "vendor/" >> .gitignore
        echo "public/assets" >> .gitignore

        git add .
        git commit -m "Rugged commit"
      COMMANDS

      system(commands)
    end

    def record_github_stats
      github_service = EngineeringMetrics::GithubStatsService.new

      current_entry.metrics[:github] = {
        code_frequency: github_service.code_frequency,
        commits_trend: github_service.commits_trend
      }

      current_entry.save!
    end
  end
end
