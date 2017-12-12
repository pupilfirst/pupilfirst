FactoryBot.define do
  factory :skill do
    name { Faker::Lorem.words(2) }
    description { Faker::Lorem.sentence }
  end
end
