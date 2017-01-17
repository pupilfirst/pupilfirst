FactoryGirl.define do
  factory :batch do
    theme { Faker::Lorem.word }
    sequence(:batch_number)
    description { Faker::Lorem.words(10).join ' ' }
    start_date { 1.month.ago }
    end_date { 5.months.from_now }

    # batch which started 1 day ago
    trait :just_started do
      start_date { 1.day.ago }
      end_date { 24.weeks.from_now }
    end

    # batch with 10 targets for startups in the first week first group
    trait :with_targets_for_startups do
      after(:create) do |batch|
        create_list(:target, 10, :with_program_week, :for_startup, batch: batch, week_number: 1, group_index: 1)
      end
    end

    trait :with_startups do
      after(:create) do |batch|
        create_list(:startup, 10, batch: batch)
      end
    end
  end
end
