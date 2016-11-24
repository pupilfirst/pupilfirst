FactoryGirl.define do
  factory :founder do
    user
    name { Faker::Name.name }
    born_on { 20.years.ago }
    gender Founder::GENDER_MALE
    email { Faker::Internet.email }
  end
end
