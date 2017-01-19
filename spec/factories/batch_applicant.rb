FactoryGirl.define do
  factory :batch_applicant do
    name { Faker::Name.name }
    email { Faker::Internet.free_email(name) }
    sequence(:phone) { |i| (9_876_543_210 + i).to_s }
    college

    trait :with_user do
      after(:create) do |batch_applicant|
        user = User.create!(email: batch_applicant.email)
        batch_applicant.update!(user: user)
      end
    end
  end
end
