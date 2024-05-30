FactoryBot.define do
  factory :course do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(" ") }
    description { Faker::Lorem.sentence }
    school { School.find_by(name: "test") || create(:school, :current) }
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

    sequence(:sort_index)

    trait(:unlimited) { progression_limit { 0 } }

    trait(:strict) { progression_limit { 1 } }

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
