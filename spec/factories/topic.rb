FactoryBot.define do
  factory :topic do
    title { Faker::Lorem.sentence }
    community
  end
end
