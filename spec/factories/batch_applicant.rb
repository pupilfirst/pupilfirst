FactoryGirl.define do
  factory :batch_applicant do
    name { Faker::Name.name }
    email { Faker::Internet.free_email(name) }
  end
end
