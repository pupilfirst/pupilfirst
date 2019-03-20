namespace :leaderboard_entries do
  desc 'Create entries in the leaderboard for last week'
  task :create, %i[course_name] => [:environment] do |_task, args|
    raise 'Course name is required as argument' if args.course_name.blank?

    lts = LeaderboardTimeService.new
    course = Course.find_by(name: args.course_name)

    raise "Could not find course with name '#{args.course_name}'" if course.blank?

    Courses::CreateLeaderboardEntriesService.new(course).execute(lts.week_start, lts.week_end)
  end
end
