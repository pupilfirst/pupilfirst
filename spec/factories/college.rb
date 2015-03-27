FactoryGirl.define do
  factory :college do
    name { Faker::Lorem.words(3).join(' ') }
    university { Faker::Lorem.words(3).join(' ') }
    city { Faker::Address.city }
    state { Faker::Address.state }
  end
end
