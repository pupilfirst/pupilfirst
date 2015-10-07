FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    # Fakers last_names do not agree with our validation rules, hence re-using first_name
    last_name { Faker::Name.first_name }
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
