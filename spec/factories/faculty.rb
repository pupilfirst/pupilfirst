FactoryBot.define do
  factory :faculty do
    user { create :user }
    name { Faker::Name.name }
    title { Faker::Job.title }
    category Faculty::CATEGORY_VR_COACHES
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'donald_duck.jpg')) }

    trait :with_email do
      email { Faker::Internet.email }
    end

    trait :connectable do
      with_email
      level { create :level, :one }
    end
  end
end
