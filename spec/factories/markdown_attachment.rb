FactoryBot.define do
  factory :markdown_attachment do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/resources/pdf-sample.pdf')) }
    token { SecureRandom.urlsafe_base64 }
    user
  end
end
