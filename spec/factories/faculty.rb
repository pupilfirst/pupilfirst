FactoryBot.define do
  factory :faculty do
    user { create :user }
    name { Faker::Name.name }
    title { Faker::Job.title }
    category { Faculty::CATEGORY_VR_COACHES }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'donald_duck.jpg')) }
    school { School.find_by(name: 'default') || create(:school, name: 'default') }
  end
end
