FactoryBot.define do
  factory :weekly_karma_point do
    startup
    week_starting_at { DatesService.last_week_start_date }
    points { [50, 60, 70, 80, 90].sample }
    level
  end
end
