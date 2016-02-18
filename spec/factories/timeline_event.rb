FactoryGirl.define do
  factory :timeline_event do
    startup
    founder { startup.admin }
    description { Faker::Lorem.words(10).join ' ' }
    event_on { 1.month.from_now }
    timeline_event_type

    factory :timeline_event_with_image do
      image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'pdf-thumbnail.png')) }
    end

    factory :timeline_event_with_links do
      links do
        [
          { title: 'Private URL', url: 'https://sv.co/private', private: true },
          { title: 'Public URL', url: 'https://google.com', private: false }
        ]
      end
    end
  end
end
