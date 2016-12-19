FactoryGirl.define do
  factory :batch do
    theme { Faker::Lorem.word }
    sequence(:batch_number)
    description { Faker::Lorem.words(10).join ' ' }
    start_date { 1.month.ago }
    end_date { 5.months.from_now }
    campaign_start_at { 1.week.ago }
    target_application_count 100

    trait :in_stage_1 do
      start_date { 3.months.from_now }
      end_date { 9.months.from_now }

      after(:create) do |batch|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)

        create :batch_stage, batch: batch, application_stage: stage_1
        create :batch_stage, batch: batch, application_stage: stage_2
        create :batch_stage, batch: batch, application_stage: stage_3, starts_at: 20.days.from_now, ends_at: 50.days.from_now
      end
    end

    trait :in_stage_2 do
      in_stage_1 # They're active together. :-)
    end

    trait :in_stage_3 do
      start_date { 2.months.from_now }
      end_date { 8.months.from_now }

      after(:create) do |batch|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)

        create :batch_stage, batch: batch, application_stage: stage_1, starts_at: 45.days.ago, ends_at: 15.days.ago
        create :batch_stage, batch: batch, application_stage: stage_2, starts_at: 45.days.ago, ends_at: 15.days.ago
        create :batch_stage, batch: batch, application_stage: stage_3, starts_at: 3.days.ago, ends_at: 4.days.from_now
      end
    end

    trait :in_stage_4 do
      start_date { 1.month.from_now }
      end_date { 7.months.from_now }

      after(:create) do |batch|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)
        stage_4 = create(:application_stage, number: 4)

        create :batch_stage, batch: batch, application_stage: stage_1, starts_at: 65.days.ago, ends_at: 35.days.ago
        create :batch_stage, batch: batch, application_stage: stage_2, starts_at: 65.days.ago, ends_at: 35.days.ago
        create :batch_stage, batch: batch, application_stage: stage_3, starts_at: 23.days.ago, ends_at: 16.days.ago
        create :batch_stage, batch: batch, application_stage: stage_4, starts_at: 3.days.ago, ends_at: 11.days.from_now
      end
    end

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
