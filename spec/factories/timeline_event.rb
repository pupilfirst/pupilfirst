FactoryGirl.define do
  factory :timeline_event do
    startup
    founder { startup.team_lead }
    description { Faker::Lorem.words(10).join ' ' }
    event_on { 1.month.from_now }
    timeline_event_type
    status TimelineEvent::STATUS_PENDING
    status_updated_at { Time.zone.now }

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

    trait :verified do
      status TimelineEvent::STATUS_VERIFIED
    end
  end
end
