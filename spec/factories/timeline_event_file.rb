FactoryBot.define do
  factory :timeline_event_file do
    transient do
      file_path { 'files/pdf-sample.pdf' }
    end

    sequence(:title) { |i| [Faker::Lorem.word, i].join ' ' }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/uploads/#{file_path}")) }
    timeline_event
  end
end
