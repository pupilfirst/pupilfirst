FactoryBot.define do
  factory :calendar do
    name { Faker::Lorem.words(number: 2).join(' ') }

    course
  end
end
