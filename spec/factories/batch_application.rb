FactoryGirl.define do
  factory :batch_application do
    batch
    application_stage
    team_lead { create :batch_applicant }
    university
    college { Faker::Lorem.words(3).join(' ') }
    team_size { (2..10).to_a.sample }

    after(:build) do |application|
      application.batch_applicants << application.team_lead
    end
  end
end
