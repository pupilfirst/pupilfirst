FactoryBot.define do
  factory :course do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(' ') }
    description { Faker::Lorem.sentence }
    school { School.find_by(name: 'test') || create(:school, :current) }
    progression_behavior { Course::PROGRESSION_BEHAVIOR_LIMITED }
    progression_limit { 1 }
    highlights do
      [
        {
          icon: Types::CourseHighlightInputType.allowed_icons.sample,
          title: Faker::Lorem.words(number: 2).join(' ').titleize,
          description: Faker::Lorem.paragraph
        },
        {
          icon: Types::CourseHighlightInputType.allowed_icons.sample,
          title: Faker::Lorem.words(number: 2).join(' ').titleize,
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
  end
end
