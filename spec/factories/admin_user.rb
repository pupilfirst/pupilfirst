FactoryBot.define do
  factory :admin_user do
    fullname { Faker::Name.name }
    email { Faker::Internet.email(name: fullname) }
  end
end
