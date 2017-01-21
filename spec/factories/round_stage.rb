FactoryGirl.define do
  factory :round_stage do
    application_round
    application_stage
    starts_at { 15.days.ago }
    ends_at { application_stage.final_stage? ? nil : 15.days.from_now }
  end
end
