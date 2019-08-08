after 'development:founders' do
  puts 'Seeding leaderboard entries (idempotent)'

  student_1 = Founder.first
  other_students = student_1.course.founders.where.not(id: student_1)

  # Add entries for last week
  lts = LeaderboardTimeService.new
  student_1.leaderboard_entries.create!(period_from: lts.week_start, period_to: lts.week_end, score: 10)

  other_students.each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.week_start, period_to: lts.week_end, score: rand(1..9))
  end

  # Add entries for two weeks before
  student_1.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 9)

  [other_students.first, other_students.second].each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 10)
  end

  # Add entries for three weeks before
  lts = LeaderboardTimeService.new(2.weeks.ago)

  other_students.each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.week_start, period_to: lts.week_end, score: 10)
  end

  # Add entries for four weeks before
  [other_students.first, other_students.second, other_students.third].each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 10)
  end

  student_1.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 9)
end
