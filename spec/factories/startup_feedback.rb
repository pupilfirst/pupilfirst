FactoryBot.define do
  factory :startup_feedback do
    feedback { Faker::Lorem.words(number: 15).join(' ') }
    reference_url { Faker::Internet.url }
    activity_type { Faker::Lorem.words(number: 5).join(' ') }
  end
end
