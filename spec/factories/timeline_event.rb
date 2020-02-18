FactoryBot.define do
  factory :timeline_event do
    description { Faker::Lorem.words(number: 10).join ' ' }
    target

    factory :timeline_event_with_links do
      links do
        [
          { title: 'Private URL', url: 'https://sv.co/private', private: true },
          { title: 'Public URL', url: 'https://google.com', private: false }
        ]
      end
    end

    trait :passed do
      passed_at { 1.day.ago }
    end

    trait(:latest) do
      latest { true }
    end
  end
end
