FactoryGirl.define do
  factory :application_submission do
    application_stage
    batch_application

    trait :stage_2_submission do
      transient do
        scored false
      end

      application_stage { create :application_stage, number: 2 }

      after(:create) do |application_submission, evaluator|
        score, admin_user = if evaluator.scored
          [rand(100), create(:admin_user)]
        else
          [nil, nil]
        end

        create :application_submission_url, application_submission: application_submission, name: 'Live Website', url: "https://example.com/#{rand(1000)}", score: score, admin_user: admin_user
        create :application_submission_url, application_submission: application_submission, name: 'Code Submission', url: "https://github.com/user#{rand(1000)}/repository", score: score, admin_user: admin_user
        create :application_submission_url, application_submission: application_submission, name: 'Video Submission', url: "https://facebook.com/user#{rand(1000)}/video", score: score, admin_user: admin_user
      end
    end

    trait :stage_3_submission do
      transient do
        scored false
      end

      application_stage { create :application_stage, number: 3 }
      score { scored ? rand(100) : nil }
    end
  end
end
