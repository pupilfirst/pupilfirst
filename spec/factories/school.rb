FactoryBot.define do
  factory :school do
    name { Faker::Lorem.words(2).join('') }
  end
end
