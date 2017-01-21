FactoryGirl.define do
  factory :application_round do
    batch
    sequence(:number)
    campaign_start_at 1.week.ago
    target_application_count 100

    # Stage 1, 2 and 3 occur together.
    trait :screening_stage do
      after(:create) do |application_round|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)
        stage_4 = create(:application_stage, number: 4)

        create :round_stage, application_round: application_round, application_stage: stage_1
        create :round_stage, application_round: application_round, application_stage: stage_2
        create :round_stage, application_round: application_round, application_stage: stage_3
        create :round_stage, application_round: application_round, application_stage: stage_4, starts_at: 20.days.from_now, ends_at: 50.days.from_now
      end
    end

    trait :video_stage do
      after(:create) do |application_round|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)
        stage_4 = create(:application_stage, number: 4)
        stage_5 = create(:application_stage, number: 5)

        create :round_stage, application_round: application_round, application_stage: stage_1, starts_at: 45.days.ago, ends_at: 15.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_2, starts_at: 45.days.ago, ends_at: 15.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_3, starts_at: 45.days.ago, ends_at: 15.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_4
        create :round_stage, application_round: application_round, application_stage: stage_5, starts_at: 20.days.from_now, ends_at: 50.days.from_now
      end
    end

    trait :interview_stage do
      after(:create) do |application_round|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)
        stage_4 = create(:application_stage, number: 4)
        stage_5 = create(:application_stage, number: 5)
        stage_6 = create(:application_stage, number: 6)

        create :round_stage, application_round: application_round, application_stage: stage_1, starts_at: 65.days.ago, ends_at: 35.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_2, starts_at: 65.days.ago, ends_at: 35.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_3, starts_at: 65.days.ago, ends_at: 35.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_4, starts_at: 23.days.ago, ends_at: 16.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_5
        create :round_stage, application_round: application_round, application_stage: stage_6, starts_at: 20.days.from_now, ends_at: 50.days.from_now
      end
    end

    trait :pre_selection_stage do
      after(:create) do |application_round|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)
        stage_4 = create(:application_stage, number: 4)
        stage_5 = create(:application_stage, number: 5)
        stage_6 = create(:application_stage, number: 6)
        stage_7 = create(:application_stage, number: 7)

        create :round_stage, application_round: application_round, application_stage: stage_1, starts_at: 90.days.ago, ends_at: 60.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_2, starts_at: 90.days.ago, ends_at: 60.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_3, starts_at: 90.days.ago, ends_at: 60.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_4, starts_at: 55.days.ago, ends_at: 35.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_5, starts_at: 23.days.ago, ends_at: 16.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_6
        create :round_stage, application_round: application_round, application_stage: stage_7, starts_at: 20.days.from_now, ends_at: 50.days.from_now
      end
    end

    trait :closed_stage do
      after(:create) do |application_round|
        stage_1 = create(:application_stage, number: 1)
        stage_2 = create(:application_stage, number: 2)
        stage_3 = create(:application_stage, number: 3)
        stage_4 = create(:application_stage, number: 4)
        stage_5 = create(:application_stage, number: 5)
        stage_6 = create(:application_stage, number: 6)
        stage_7 = create(:application_stage, number: 7)

        create :round_stage, application_round: application_round, application_stage: stage_1, starts_at: 120.days.ago, ends_at: 91.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_2, starts_at: 120.days.ago, ends_at: 91.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_3, starts_at: 120.days.ago, ends_at: 91.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_4, starts_at: 90.days.ago, ends_at: 60.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_5, starts_at: 55.days.ago, ends_at: 35.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_6, starts_at: 23.days.ago, ends_at: 16.days.ago
        create :round_stage, application_round: application_round, application_stage: stage_7, starts_at: 2.days.ago
      end
    end
  end
end
