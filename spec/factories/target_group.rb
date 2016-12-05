FactoryGirl.define do
  factory :target_group do
    name { Faker::Lorem.word }
    program_week
    sequence(:number) { |n| n + 1 }
    description { Faker::Lorem.sentence }
  end
end
