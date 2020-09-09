FactoryBot.define do
  factory :target do
    title { Faker::Lorem.words(number: 6).join ' ' }
    role { Target.valid_roles.sample }
    target_group
    sequence(:sort_index)
    visibility { Target::VISIBILITY_LIVE }

    trait :archived do
      safe_to_change_visibility { true }
      visibility { Target::VISIBILITY_ARCHIVED }
    end

    trait :draft do
      safe_to_change_visibility { true }
      visibility { Target::VISIBILITY_DRAFT }
    end

    trait :session do
      session_at { 1.week.from_now }
      days_to_complete { nil }
    end

    trait :for_founders do
      role { Target::ROLE_STUDENT }
    end

    trait :for_team do
      role { Target::ROLE_TEAM }
    end

    trait :team do
      role { Target::ROLE_TEAM }
    end

    trait :student do
      role { Target::ROLE_STUDENT }
    end

    trait :with_default_checklist do
      checklist { [{ kind: Target::CHECKLIST_KIND_LONG_TEXT, title: 'Write something about your submission', optional: false }] }
    end

    trait :with_markdown do
      after(:create) do |target|
        target_version = create(:target_version, target: target)
        create(:content_block, :empty_markdown, target_version: target_version)
      end
    end

    trait :with_content do
      after(:create) do |target|
        target_version = create(:target_version, target: target)
        create(:content_block, :image, target_version: target_version)
        create(:content_block, :markdown, target_version: target_version)
        create(:content_block, :file, target_version: target_version)
        create(:content_block, :embed, target_version: target_version)
      end
    end

    trait :with_file do
      after(:create) do |target|
        target_version = create(:target_version, target: target)
        create(:content_block, :file, target_version: target_version)
      end
    end

    trait :with_group do
      target_group { nil } # We'll add it later.

      transient do
        milestone { false }
        level { create :level }
      end

      after(:build) do |target, evaluator|
        target.target_group = create(:target_group, level: evaluator.level, milestone: evaluator.milestone)
      end
    end
  end
end
