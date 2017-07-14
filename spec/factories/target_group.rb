FactoryGirl.define do
  factory :target_group do
    name { Faker::Lorem.word }
    sequence(:sort_index)
    description { Faker::Lorem.sentence }
    level
  end
end
