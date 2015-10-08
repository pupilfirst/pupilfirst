FactoryGirl.define do
  factory :startup_category do
    name { Faker::Lorem.words(2).join(' ') }
  end
end
