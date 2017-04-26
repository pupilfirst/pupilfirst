FactoryGirl.define do
  factory :weekly_karma_point do
    startup { create :startup }
    points { [50, 60, 70, 80, 90].sample }
    level { create :level, :one }
  end
end
