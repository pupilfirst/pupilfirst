FactoryBot.define do
  factory :timeline_event_file do
    transient { file_path { "files/pdf-sample.pdf" } }

    sequence(:title) { |i| [Faker::Lorem.word, i].join " " }
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/support/uploads/#{file_path}")
      )
    end
    user
    timeline_event
  end
end
