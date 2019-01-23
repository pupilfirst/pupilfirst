FactoryBot.define do
  factory :faculty do
    user { create :user }
    name { Faker::Name.name }
    title { Faker::Job.title }
    category { Faculty::CATEGORY_VR_COACHES }
  end
end
