FactoryBot.define do
  factory :cohort do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(' ') }
    description { Faker::Lorem.sentences(number: 2).join(' ') }

    course
  end
end
