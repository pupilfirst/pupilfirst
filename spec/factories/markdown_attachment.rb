FactoryBot.define do
  factory :markdown_attachment do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/files/pdf-sample.pdf')) }
    token { SecureRandom.urlsafe_base64 }
    user
    school { School.find_by(name: 'test') || create(:school, :current) }
  end
end
