FactoryGirl.define do
  factory :target do
    initialize_with { key.present? ? Target.where(key: key).first_or_initialize(attributes) : Target.new(attributes) }

    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    description { Faker::Lorem.words(200).join ' ' }
    target_action_type { Target.valid_target_action_types.sample }
    days_to_complete { 1 + rand(60) }
    target_group
    timeline_event_type
    key nil
    sequence(:sort_index)

    transient do
      batch nil
      week_number nil
      group_index nil
    end

    trait :for_founders do
      role Target::ROLE_FOUNDER
    end

    trait :for_startup do
      role { Founder.valid_roles.sample }
    end

    trait :with_rubric do
      rubric { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }
    end

    trait(:admissions_cofounder_addition) do
      key Target::KEY_ADMISSIONS_COFOUNDER_ADDITION
      role Target::ROLE_TEAM
      prerequisite_targets { [create(:target, :admissions_screening)] }
    end

    trait(:admissions_fee_payment) do
      key Target::KEY_ADMISSIONS_FEE_PAYMENT
      role Target::ROLE_TEAM
      prerequisite_targets { [create(:target, :admissions_cofounder_addition)] }
    end

    trait(:admissions_screening) do
      key Target::KEY_ADMISSIONS_SCREENING
      role Target::ROLE_TEAM
    end

    trait(:admissions_attend_interview) do
      role Target::ROLE_TEAM
      key Target::KEY_ADMISSIONS_ATTEND_INTERVIEW
      prerequisite_targets { [create(:target, :admissions_cofounder_addition)] }
    end
  end
end
