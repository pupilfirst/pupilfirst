FactoryBot.define do
  factory :cohort do
    sequence(:name) { |n| "Test Cohort #{n}" }
    description { Faker::Lorem.sentences(number: 2).join(' ') }

    course
  end
end
