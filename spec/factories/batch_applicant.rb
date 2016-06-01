FactoryGirl.define do
  factory :batch_applicant do
    email { Faker::Internet.email }
  end
end
