module Courses
  class CreateLeaderboardEntriesService
    # @param course [Course] Course for which leaderboard entries are to be created.
    def initialize(course)
      @course = course
    end

    # @param period_from [ActiveSupport::TimeWithZone] Opening time for the leaderboard.
    # @param period_to [ActiveSupport::TimeWithZone] Closing time for the leaderboard.
    def execute(period_from, period_to)
      founders = @course.founders.where(exited: false, excluded_from_leaderboard: false)
      Rails.logger.info("Recording leaderboard entries for #{founders.count} students...")

      LeaderboardEntry.transaction do
        entries = founders.each_with_object([]) do |founder, leaderboard_entries|
          score = founder.timeline_events.where(created_at: [period_from..period_to]).sum do |timeline_event|
            grade_score = timeline_event.timeline_event_grades.sum(:grade)
            grade_score.positive? ? grade_score : 1
          end

          next if score.zero?

          leaderboard_entries << LeaderboardEntry.create!(founder: founder, period_from: period_from, period_to: period_to, score: score)
        end

        Rails.logger.info("Recorded #{entries.count} leaderboard entries!")
      end
    end
  end
end
