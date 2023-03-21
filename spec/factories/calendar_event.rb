FactoryBot.define do
  factory :calendar_event do
    title { Faker::Lorem.words(number: 5).join(' ') }
    description { Faker::Lorem.sentences(number: 2).join(' ') }
    start_time { Time.zone.now }
    calendar
    color { CalendarEvent.colors.keys.sample }

    trait :with_link do
      link_url { Faker::Internet.url }
      link_title { Faker::Lorem.words(number: 2).join(' ') }
    end
  end
end
