FactoryGirl.define do
  factory :timeline_event_file do
    sequence(:title) { |i| [Faker::Lorem.word, i].join ' ' }
    file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }
    timeline_event
  end
end
