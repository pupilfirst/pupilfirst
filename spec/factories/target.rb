FactoryBot.define do
  factory :target do
    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    target_group
    sequence(:sort_index)
    visibility { Target::VISIBILITY_LIVE }

    trait :archived do
      safe_to_archive { true }
      visibility { Target::VISIBILITY_ARCHIVED }
    end

    trait :draft do
      visibility { Target::VISIBILITY_DRAFT }
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

    trait :with_content do
      after(:create) do |target|
        create(:content_block, :embed, target: target)
        create(:content_block, :markdown, target: target)
        create(:content_block, :image, target: target)
        create(:content_block, :file, target: target)
      end
    end
  end
end
