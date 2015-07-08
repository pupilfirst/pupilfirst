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
    salutation { %w(Mr Miss Mrs).sample }
    email { Faker::Internet.email }
    born_on { Date.current.to_s }
    gender { %w(male female).sample }
    title { Faker::Lorem.characters(9) }
    communication_address { Faker::Address.secondary_address }
    district { Faker::Address.city }
    state { Faker::Address.state }
    pin { (rand(899999) + 100000).to_s }
    avatar { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    twitter_url { 'http://' + Faker::Internet.domain_name }
    linkedin_url { 'http://' + Faker::Internet.domain_name }
    college {create(:college)}
    factory :user_with_out_password do
      skip_password true

      factory :founder do
        is_founder true
      end

      factory :user_with_facebook do
        after(:create) do |user, evaluator|
          create_list(:facebook_social_id, 1, user: user)
        end
      end

      factory :user_as_contact, aliases: [:contact] do
        is_contact true
        sequence(:phone) { |n| "#{9876543210 + n}" }
        company { "#{Faker::Name.last_name} Ltd." }
        invitation_token { Faker::Lorem.characters 10 }
      end
    end

    factory :user_with_password do
      password "user_password"
      password_confirmation "user_password"
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

  factory :bank do |f|
    f.is_joint true
    startup
  end

  factory :request  do
    association :user, factory: :founder
    body { Faker::Lorem.words(15).join ' ' }
  end

end
