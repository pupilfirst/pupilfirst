FactoryBot.define do
  factory :certificate do
    course
    qr_corner { %w[TopLeft TopRight BottomRight BottomLeft Hidden].sample }
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
