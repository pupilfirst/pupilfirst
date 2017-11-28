puts 'Seeding engineering_metrics'

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3700 + rand(100)}" },
  week_start_at: Time.zone.now.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3650 + rand(100)}" },
  week_start_at: 1.week.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3600 + rand(100)}" },
  week_start_at: 2.weeks.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3550 + rand(100)}" },
  week_start_at: 3.weeks.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3500 + rand(100)}" },
  week_start_at: 4.weeks.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3450 + rand(100)}" },
  week_start_at: 5.weeks.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3400 + rand(100)}" },
  week_start_at: 6.weeks.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3350 + rand(100)}" },
  week_start_at: 7.weeks.ago.beginning_of_week
)

EngineeringMetric.create!(
  metrics: { 'deploys' => 5 + rand(20), 'release_version' => "v#{3300 + rand(100)}" },
  week_start_at: 8.weeks.ago.beginning_of_week
)
