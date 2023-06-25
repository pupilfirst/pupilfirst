FactoryBot.define do
  factory :course do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(" ") }
    description { Faker::Lorem.sentence }
    school { School.find_by(name: "test") || create(:school, :current) }
    progression_behavior { Course::PROGRESSION_BEHAVIOR_LIMITED }
    progression_limit { 2 }
    highlights do
      [
        {
          icon: Types::CourseHighlightInputType.allowed_icons.sample,
          title: Faker::Lorem.words(number: 2).join(" ").titleize,
          description: Faker::Lorem.paragraph
        },
        {
          icon: Types::CourseHighlightInputType.allowed_icons.sample,
          title: Faker::Lorem.words(number: 2).join(" ").titleize,
          description: Faker::Lorem.paragraph
        }
      ]
    end

    trait(:unlimited) do
      progression_behavior { Course::PROGRESSION_BEHAVIOR_UNLIMITED }
      progression_limit { nil }
    end

    trait(:strict) do
      progression_behavior { Course::PROGRESSION_BEHAVIOR_STRICT }
      progression_limit { nil }
    end

    trait :archived do
      archived_at { 1.day.ago }
      after(:create) do |course|
        create :cohort, course: course, ends_at: 1.day.ago
      end
    end

    trait :ended do
      after(:create) do |course|
        create :cohort, course: course, ends_at: 1.day.ago
      end
    end

    trait :with_cohort do
      after(:create) { |course| create :cohort, course: course }
    end

    trait :with_default_cohort do
      after(:create) do |course|
        cohort = create :cohort, course: course
        course.update!(default_cohort: cohort)
      end
    end
  end
end
