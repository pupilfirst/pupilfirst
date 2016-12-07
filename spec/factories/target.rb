FactoryGirl.define do
  factory :target do
    title { Faker::Lorem.words(6).join ' ' }
    role { Target.valid_roles.sample }
    description { Faker::Lorem.words(200).join ' ' }
    target_type { Target.valid_target_types.sample }
    days_to_complete { 1 + rand(60) }
    batch

    transient do
      week_number nil
    end

    trait :with_program_week do
      target_group { create :target_group, batch: batch, week_number: week_number }
    end
  end
end
