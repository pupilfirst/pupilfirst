FactoryBot.define do
  factory :applicant do
    email { Faker::Internet.email(name: name) }
    name { Faker::Name.name }
    course

    trait :verified do
      email_verified { true }
    end
  end
end
