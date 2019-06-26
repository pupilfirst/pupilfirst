FactoryBot.define do
  factory :faculty do
    user
    category { Faculty::CATEGORY_VR_COACHES }
    school

    after(:create) do |faculty|
      UserProfile.where(user: faculty.user, school: faculty.school).first_or_create!(
        name: Faker::Name.name,
        title: Faker::Lorem.words(3).join(' ')
      )
    end
  end
end
