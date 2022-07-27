FactoryBot.define do
  factory :cohort do
    initialize_with { Cohort.where(course: course).first_or_create }

    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(' ') }
    description { Faker::Lorem.sentences(number: 2).join(' ') }

    course
  end
end
