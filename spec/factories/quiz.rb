FactoryBot.define do
  factory :quiz do
    title { Faker::Lorem.words(number: 2) }
  end
end
