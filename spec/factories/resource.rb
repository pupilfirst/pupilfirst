FactoryBot.define do
  factory :resource do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/resources/pdf-sample.pdf'), 'application/pdf') }
    title { Faker::Lorem.words(number: 6).join ' ' }
    description { Faker::Lorem.words(number: 12).join ' ' }
    school

    factory :resource_video_file do
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/resources/video-sample.mp4')) }
    end

    factory :resource_video_embed do
      file { nil }
      video_embed { '<iframe width="560" height="315" src="https://www.youtube.com/embed/nkzqJ-9u4Aw" frameborder="0" allowfullscreen></iframe>' }
    end

    factory :resource_link do
      file { nil }
      link { 'https://www.google.com' }
    end
  end
end
