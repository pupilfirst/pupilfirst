FactoryGirl.define do
  factory :faculty do
    name { Faker::Name.name }
    title { Faker::Name.title }
    category Faculty::CATEGORY_TEAM
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'donald_duck.jpg')) }
    email { Faker::Internet.email }
  end
end
