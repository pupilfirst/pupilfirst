FactoryGirl.define do
  factory :target do
    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    description { Faker::Lorem.words(200).join ' ' }
    target_type { Target.valid_target_types.sample }
    days_to_complete { 1 + rand(60) }

    batch do
      if target_group.present?
        target_group.program_week.batch
      else
        create :batch
      end
    end

    transient do
      week_number nil
      group_index nil
    end

    trait :for_startup do
      role { Founder.valid_roles.sample }
    end

    trait :with_rubric do
      rubric { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }
    end

    trait :with_program_week do
      target_group { TargetGroup.find_by(sort_index: group_index) || create(:target_group, batch: batch, week_number: week_number) }
    end
  end
end
