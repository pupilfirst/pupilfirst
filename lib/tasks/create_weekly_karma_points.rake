desc 'Creates weekly karma points for startups to generate leaderboards by weeks'
task create_weekly_karma_points: :environment do
  WeeklyKarmaPoints::CreateService.new.execute
end
