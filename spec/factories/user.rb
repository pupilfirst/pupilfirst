FactoryGirl.define do
  factory :user do
    # Since name validation is strict, and we can't rely on Faker to supply proper names, we'll restrict the set.
    first_name { %w(Douglas Oren Arlie Libby Ilene Lorenzo Sebastian Micheal Kari Tina).sample }
    last_name { %w(Simonis Marquardt Torphy McCullough Funk Sporer Heller Yundt McGlynn Lang).sample }

    born_on { 20.years.ago }
    gender User::GENDER_MALE

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
