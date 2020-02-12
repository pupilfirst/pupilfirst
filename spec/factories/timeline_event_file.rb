FactoryBot.define do
  factory :timeline_event_file do
    sequence(:title) { |i| [Faker::Lorem.word, i].join ' ' }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/resources/pdf-sample.pdf')) }
    timeline_event
  end
end
