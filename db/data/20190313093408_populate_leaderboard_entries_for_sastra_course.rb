class PopulateLeaderboardEntriesForSastraCourse < ActiveRecord::Migration[5.2]
  def up
    course = Course.find_by(name: 'Sastra VR-201')

    (0..8).each do |week_number|
      leaderboard_at = Time.zone.now - week_number.weeks

      lp = Courses::LeaderboardPresenter.new(:foo, course, leaderboard_at)

      period_from =  lp.send(:last_week_start_time)
      period_to = lp.send(:last_week_end_time)

      Courses::CreateLeaderboardEntriesService.new(course).execute(period_from, period_to)
    end
  end

  def down
    LeaderboardEntry.destroy_all
  end
end
