FactoryBot.define do
  factory :certificate do
    course
    sequence(:name) { |i| Faker::Lorem.words(number: 2).join(' ') + " #{i}" }
    qr_corner { 'Hidden' }
    qr_scale { 100 }
    name_offset_top { 50 }
    font_size { 100 }
    margin { 5 }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/certificates/sample.png'), 'image/png') }

    trait :active do
      active { true }
    end
  end
end
