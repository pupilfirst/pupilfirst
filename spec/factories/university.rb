FactoryGirl.define do
  factory :university do
    name { Faker::Lorem.words(3).join(' ') }
    location { Faker::Lorem.word }
  end
end
