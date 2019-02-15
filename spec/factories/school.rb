FactoryBot.define do
  factory :school do
    name { Faker::Lorem.words(2).join(' ') }

    trait(:current) do
      name { 'test' }
    end
  end
end
