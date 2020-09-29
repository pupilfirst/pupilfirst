FactoryBot.define do
  factory :topic_category do
    name { Faker::Lorem.word }
    community
  end
end
