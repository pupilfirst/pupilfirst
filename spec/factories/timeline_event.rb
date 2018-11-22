FactoryBot.define do
  factory :timeline_event do
    startup
    founder { startup.team_lead }
    description { Faker::Lorem.words(10).join ' ' }
    event_on { 1.month.from_now }
    status_updated_at { Time.zone.now }
    target

    factory :timeline_event_with_image do
      image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-thumbnail.png')) }
    end

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
  end
end
