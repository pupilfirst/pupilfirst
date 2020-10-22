FactoryBot.define do
  factory :topic_category do
    name { Faker::Lorem.unique.word }
    community
  end
end
