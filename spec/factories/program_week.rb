FactoryGirl.define do
  factory :program_week do
    name { Faker::Lorem.word }
    sequence(:number) { |n| n + 1 }
    batch
  end
end
