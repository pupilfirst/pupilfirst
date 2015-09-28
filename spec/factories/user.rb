FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    email { Faker::Internet.email }

    factory :user_with_out_password do
      skip_password true

      factory :founder do
        is_founder true
      end
    end

    factory :user_with_password do
      password 'password'
      password_confirmation 'password'
    end
  end
end
