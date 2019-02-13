FactoryBot.define do
  factory :target do
    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    description { Faker::Lorem.words(200).join ' ' }
    target_action_type { Target.valid_target_action_types.sample }
    days_to_complete { session_at.present? ? nil : rand(1..60) }
    target_group
    faculty { create :faculty, category: Faculty::CATEGORY_TEAM }
    sequence(:sort_index)
    session_at { nil }

    trait :archived do
      safe_to_archive { true }
      archived { true }
    end

    trait :session do
      session_at { 1.week.from_now }
      days_to_complete { nil }
    end

    trait :for_founders do
      role { Target::ROLE_FOUNDER }
    end

    trait :for_startup do
      role { Target::ROLE_TEAM }
    end
  end
end
