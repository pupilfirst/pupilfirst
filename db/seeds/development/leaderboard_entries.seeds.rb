after 'development:founders' do
  puts 'Seeding leaderboard entries (idempotent)'

  john_doe = Founder.find_by(name: 'John Doe')
  other_founders = john_doe.course.founders.where.not(id: john_doe)

  # Add entries for last week
  lts = LeaderboardTimeService.new(0)
  john_doe.leaderboard_entries.create!(period_from: lts.week_start, period_to: lts.week_end, score: 10)

  other_founders.each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.week_start, period_to: lts.week_end, score: rand(1..9))
  end

  # Add entries for two weeks before
  john_doe.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 9)

  [other_founders.first, other_founders.second].each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 10)
  end

  # Add entries for three weeks before
  lts = LeaderboardTimeService.new(2)

  other_founders.each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.week_start, period_to: lts.week_end, score: 10)
  end

  # Add entries for four weeks before
  [other_founders.first, other_founders.second, other_founders.third].each do |other_founder|
    other_founder.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 10)
  end

  john_doe.leaderboard_entries.create!(period_from: lts.last_week_start, period_to: lts.last_week_end, score: 9)
end
