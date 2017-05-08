FactoryGirl.define do
  factory :program_week do
    name { Faker::Lorem.words(3).join(' ') }
    sequence(:number)
    batch
  end
end
