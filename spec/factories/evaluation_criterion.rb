FactoryBot.define do
  factory :evaluation_criterion do
    name { Faker::Lorem.words(2) }
    description { Faker::Lorem.sentence }
  end
end
