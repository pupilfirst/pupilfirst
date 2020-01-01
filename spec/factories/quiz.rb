FactoryBot.define do
  factory :quiz do
    title { Faker::Lorem.words(2) }
  end
end
