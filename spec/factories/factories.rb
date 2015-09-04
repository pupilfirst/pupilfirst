# This will guess the User class

include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :admin_user, aliases: [:author] do
    fullname { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    username  { Faker::Name.first_name }
    email { Faker::Internet.email }
    password  "password"
    password_confirmation "password"
  end

  factory :user do
    fullname { Faker::Name.name }
    email { Faker::Internet.email }

    factory :user_with_out_password do
      skip_password true

      factory :founder do
        is_founder true
      end
    end
  end

  factory :name do
    first_name  "first_name"
    last_name  "last_name"
    middle_name  "middle_name"
  end

  factory :user_category, class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :user
  end

  factory :startup_category,  class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :startup
  end
end
