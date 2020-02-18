FactoryBot.define do
  factory :applicant do
    email { Faker::Internet.email(name: name) }
    name { Faker::Name.name }
    course
  end
end
