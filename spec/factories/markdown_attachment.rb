FactoryBot.define do
  factory :markdown_attachment do
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/support/uploads/files/pdf-sample.pdf')
      )
    end
    token { SecureRandom.urlsafe_base64 }
    user
    school { School.find_by(name: 'test') || create(:school, :current) }
  end
end
