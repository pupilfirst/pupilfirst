module Courses
  class CreateLeaderboardEntriesService
    include Loggable

    # @param course [Course] Course for which leaderboard entries are to be created.
    def initialize(course)
      @course = course
    end

    # @param period_from [ActiveSupport::TimeWithZone] Opening time for the leaderboard.
    # @param period_to [ActiveSupport::TimeWithZone] Closing time for the leaderboard.
    def execute(period_from, period_to)
      students = @course.students.active.where(excluded_from_leaderboard: false)
      log("Recording leaderboard entries for #{students.count} students in Course##{@course.id}...")

      LeaderboardEntry.transaction do
        entries = students.each_with_object([]) do |student, leaderboard_entries|
          score = student.timeline_events.where(passed_at: [period_from..period_to]).sum do |timeline_event|
            grade_score = timeline_event.timeline_event_grades.sum(:grade)
            grade_score.positive? ? grade_score : 1
          end

          next if score.zero?

          leaderboard_entries << LeaderboardEntry.create!(student: student, period_from: period_from, period_to: period_to, score: score)
        end

        log("Recorded #{entries.count} leaderboard entries!")
      end
    end
  end
end
