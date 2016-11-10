FactoryGirl.define do
  factory :batch_application do
    batch
    application_stage { create :application_stage, number: 1 }
    team_lead { create :batch_applicant }
    college

    after(:build) do |application|
      application.batch_applicants << application.team_lead
    end

    trait :payment_requested do
      team_size { (2..10).to_a.sample }

      after(:create) do |application|
        create :payment, batch_application: application, batch_applicant: application.team_lead
      end
    end

    trait :paid do
      team_size { (2..10).to_a.sample }
      application_stage { create :application_stage, number: 2 }

      after(:create) do |application|
        create :payment, batch_application: application, batch_applicant: application.team_lead, paid_at: Time.now
      end
    end

    trait :stage_2_submitted do
      paid

      after(:create) do |application|
        create :application_submission, :stage_2_submission, batch_application: application, scored: true
      end
    end

    trait :stage_3 do
      stage_2_submitted
      application_stage { create :application_stage, number: 3 }
    end
  end
end
