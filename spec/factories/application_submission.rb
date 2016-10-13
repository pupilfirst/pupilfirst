FactoryGirl.define do
  factory :application_submission do
    application_stage
    batch_application

    trait :stage_2_submission do
      application_stage { create :application_stage, number: 2 }

      after(:create) do |application_submission|
        create :application_submission_url, application_submission: application_submission, name: 'Live Website', url: "https://example.com/#{rand(1000)}"
        create :application_submission_url, application_submission: application_submission, name: 'Code Submission', url: "https://github.com/user#{rand(1000)}/repository"
        create :application_submission_url, application_submission: application_submission, name: 'Video Submission', url: "https://facebook.com/user#{rand(1000)}/video"
      end
    end
  end
end
