FactoryGirl.define do
  factory :karma_point do
    founder { create :founder }
    points { [10, 20, 30, 40, 50].sample }
    activity_type { Faker::Lorem.words(10).join ' ' }

    trait :for_last_week do
      created_at { 7.days.ago }
    end
  end
end
