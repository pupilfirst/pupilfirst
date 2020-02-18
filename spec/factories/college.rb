FactoryBot.define do
  factory :college do
    name { Faker::Lorem.words(number: 3).join(' ') }
    city { Faker::Address.city }
    state

    after(:build) do |college|
      # Use the same state as college.
      college.university = create(:university, state: college.state)
    end
  end
end
