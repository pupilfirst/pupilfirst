class PopulateLeaderboardEntriesForSastraCourse < ActiveRecord::Migration[5.2]
  STUDENTS_EXCLUDED_FROM_LEADERBOARD = [
    'Reena Singh',
    'Pratham Sehgal',
    'Bodhish',
    'Bharathy',
    'Sowndarya',
    'Prawin'
  ]

  def up
    course = Course.find_by(name: 'Sastra VR-201')

    course.founders.where(name: STUDENTS_EXCLUDED_FROM_LEADERBOARD).update(excluded_from_leaderboard: true)

    (0..8).each do |week_number|
      lts = LeaderboardTimeService.new(week_number)
      Courses::CreateLeaderboardEntriesService.new(course).execute(lts.week_start, lts.week_end)
    end
  end

  def down
    LeaderboardEntry.destroy_all
  end
end
