FactoryBot.define do
  factory :admin_user do
    fullname { Faker::Name.name }
    email { Faker::Internet.email(fullname) }
  end
end
