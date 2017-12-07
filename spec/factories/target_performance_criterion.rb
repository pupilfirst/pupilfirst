FactoryBot.define do
  factory :target_performance_criterion do
    rubric_good { Faker::Lorem.sentence }
    rubric_great { Faker::Lorem.sentence }
    rubric_wow { Faker::Lorem.sentence }
    base_karma_points { [10, 20, 30, 40, 50].sample }
  end
end
