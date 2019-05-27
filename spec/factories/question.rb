FactoryBot.define do
  factory :question do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    community
    creator
  end
end
