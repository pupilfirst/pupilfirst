FactoryGirl.define do
  factory :resource do
    file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }
    thumbnail { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'pdf-thumbnail.png')) }
    title { Faker::Lorem.words(6).join ' ' }
    description { Faker::Lorem.words(12).join ' ' }
    share_status Resource::SHARE_STATUS_PUBLIC

    factory :video_resource do
      file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'video-sample.mp4')) }
      thumbnail { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'video-thumbnail.png')) }
    end
  end
end
