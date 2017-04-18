FactoryGirl.define do
  factory :target do
    initialize_with { key.present? ? Target.where(key: key).first_or_initialize(attributes) : Target.new(attributes) }

    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    description { Faker::Lorem.words(200).join ' ' }
    target_type { Target.valid_target_types.sample }
    days_to_complete { 1 + rand(60) }
    target_group
    timeline_event_type
    key nil

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

    trait :with_program_week do
      target_group { TargetGroup.find_by(sort_index: group_index) || create(:target_group) }
    end

    trait(:admissions_cofounder_addition) do
      key Target::KEY_ADMISSIONS_COFOUNDER_ADDITION
      role Target::ROLE_TEAM
      prerequisite_targets { [create(:target, :admissions_fee_payment)] }
    end

    trait(:admissions_fee_payment) do
      key Target::KEY_ADMISSIONS_FEE_PAYMENT
      role Target::ROLE_TEAM
      prerequisite_targets { [create(:target, :admissions_screening)] }
    end

    trait(:admissions_screening) do
      key Target::KEY_ADMISSIONS_SCREENING
      role Target::ROLE_TEAM
    end
  end
end
