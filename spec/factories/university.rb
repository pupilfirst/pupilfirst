FactoryGirl.define do
  factory :university do
    name { Faker::Lorem.words(3).join(' ') }
  end
end
