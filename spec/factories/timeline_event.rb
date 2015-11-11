FactoryGirl.define do
  factory :timeline_event do
    startup
    description { Faker::Lorem.words(10).join ' ' }
    links { [{ title: 'Google', url: 'https://google.com', private: 'false' }, { title: 'Yahoo', url: 'https://yahoo.com', private: 'true' }] }
    event_on { 1.month.from_now }
    timeline_event_type
  end
end
