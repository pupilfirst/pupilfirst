FactoryBot.define do
  factory :evaluation_criterion do
    name { Faker::Lorem.words(2).join(' ') }
    description { Faker::Lorem.sentence }
  end
end
