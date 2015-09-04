FactoryGirl.define do
  factory :admin_user do
    fullname { Faker::Name.name }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
  end
end
