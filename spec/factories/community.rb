FactoryBot.define do
  factory :community do
    name { Faker::Lorem.words(2).join(' ') }
    school
  end
end
