FactoryBot.define do
  factory :course do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(' ') }
    description { Faker::Lorem.sentence }
    school { School.find_by(name: 'test') || create(:school, :current) }
    progression_behavior { Course::PROGRESSION_BEHAVIOR_LIMITED }
    progression_limit { 1 }

    trait(:unlimited) do
      progression_behavior { Course::PROGRESSION_BEHAVIOR_UNLIMITED }
      progression_limit { nil }
    end

    trait(:strict) do
      progression_behavior { Course::PROGRESSION_BEHAVIOR_STRICT }
      progression_limit { nil }
    end

    trait(:with_one_level) do
      after(:create) do |course|
        Level.where(course: course, number: 1).first_or_create!(name: 'Test Level')
      end
    end
  end
end
