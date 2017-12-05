FactoryBot.define do
  factory :university do
    name { Faker::Lorem.words(3).join(' ') }
    state
  end
end
