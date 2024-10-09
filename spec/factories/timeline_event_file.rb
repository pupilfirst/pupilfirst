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

    # Define a trait for image file.
    trait :image do
      transient { file_path { "files/icon_pupilfirst.png" } }

      file do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/support/uploads/#{file_path}")
        )
      end
    end
  end
end
