namespace :leaderboard_entries do
  desc 'Create entries in the leaderboard for last week'
  task :create, %i[course_name] => [:environment] do
    lts = LeaderboardTimeService.new

    Course.where(enable_leaderboard: true).find_each do |course|
      Courses::CreateLeaderboardEntriesService.new(course).execute(lts.week_start, lts.week_end)
    end
  end
end
