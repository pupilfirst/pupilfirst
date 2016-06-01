FactoryGirl.define do
  factory :batch_application do
    batch
    application_stage
    team_lead { create :batch_applicant }

    after(:build) do |application|
      application.batch_applicants << application.team_lead
      2.times { application.batch_applicants << create(:batch_applicant) }
    end
  end
end
