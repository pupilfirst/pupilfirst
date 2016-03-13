FactoryGirl.define do
  factory :startup_category do
    sequence(:name) { |i| Faker::Lorem.words(2).push(i).join(' ') }
  end
end
