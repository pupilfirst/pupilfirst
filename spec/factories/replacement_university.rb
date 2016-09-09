FactoryGirl.define do
  factory :replacement_university do
    name { Faker::Lorem.words(3).join(' ') }
    state
  end
end
