FactoryBot.define do
  factory :faculty do
    user { create :user }
    name { Faker::Name.name }
    title { Faker::Job.title }
    category { Faculty::CATEGORY_VR_COACHES }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'donald_duck.jpg')) }
    level { create :level, :one }
  end
end
