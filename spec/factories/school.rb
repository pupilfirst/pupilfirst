FactoryBot.define do
  factory :school do
    name { Faker::Lorem.words(number: 2).join(' ') }

    trait(:current) do
      name { 'test' }

      after(:create) do |school|
        Domain.where(school: school, fqdn: 'test.host').first_or_create!(
          primary: true
        )
      end
    end
  end
end
