FactoryGirl.define do
  factory :batch_stage do
    batch
    application_stage
    starts_at { 15.days.ago }
    ends_at { 15.days.from_now }
  end
end
