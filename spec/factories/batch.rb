FactoryGirl.define do
  factory :batch do
    theme { Faker::Lorem.word }
    sequence(:batch_number) { |n| n + 1 }
    description { Faker::Lorem.words(10).join ' ' }
    start_date { 1.month.ago }
    end_date { 5.months.from_now }

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
  end
end
