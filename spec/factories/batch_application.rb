FactoryGirl.define do
  factory :batch_application do
    batch
    application_stage
    team_lead { create :batch_applicant }
    university
    college { Faker::Lorem.words(3).join(' ') }
    state { Faker::Address.state }
    team_achievement { Faker::Lorem.paragraph }

    after(:build) do |application|
      application.batch_applicants << application.team_lead
      2.times { application.batch_applicants << create(:batch_applicant) }
    end
  end
end
