FactoryGirl.define do
  factory :target do
    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    description { Faker::Lorem.words(200).join ' ' }
    target_type { Target.valid_target_types.sample }
    days_to_complete { 1 + rand(60) }
    target_group

    transient do
      batch nil
      week_number nil
      group_index nil
    end

    trait :for_startup do
      role { Founder.valid_roles.sample }
    end

    trait :with_rubric do
      rubric { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }
    end

    trait :with_program_week do
      target_group { TargetGroup.find_by(sort_index: group_index) || create(:target_group, batch: batch, week_number: week_number) }
    end
  end
end
