FactoryGirl.define do
  factory :startup_feedback do
    feedback { Faker::Lorem.words(15).join(' ') }
    reference_url { Faker::Internet.url }
    activity_type { Faker::Lorem.words(5).join(' ') }
  end
end
