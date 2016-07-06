FactoryGirl.define do
  factory :batch_applicant do
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
