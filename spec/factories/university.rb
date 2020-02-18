FactoryBot.define do
  factory :university do
    name { Faker::Lorem.words(number: 3).join(' ') }
    state
  end
end
