FactoryBot.define do
  factory :leaderboard_entry do
    founder
    period_from { 2.weeks.ago }
    period_to { 1.week.ago }
    score { rand(1..20) }
  end
end
