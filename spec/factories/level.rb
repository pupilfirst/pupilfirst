FactoryGirl.define do
  factory :level do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    sequence(:number)
  end
end
