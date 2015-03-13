# This will guess the User class

include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :admin_user, aliases: [:author] do
    fullname { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    username  { Faker::Name.first_name }
    email     { Faker::Internet.email }
    password  "password"
    password_confirmation "password"
  end

  factory :social_id do
    social_id       {Faker::Number.number(8)}
    social_token    {Faker::Lorem.characters(256)}
    permission      []
    # association :user, factory: :user_with_out_password, strategy: :build
    factory :facebook_social_id do
      provider :facebook
      primary  true
    end
  end

  factory :user do
    fullname { Faker::Name.name }
    username  { Faker::Lorem.characters(9) }
    salutation { %w(Mr Miss Mrs).sample }
    email     { Faker::Internet.email }
    born_on   { Date.current.to_s }
    title   { Faker::Lorem.characters(9) }
    street_address { "#{Faker::Address.secondary_address},\n#{Faker::Address.street_address},\n#{Faker::Address.city}" }
    district { Faker::Address.city }
    state { Faker::Address.state }
    pin { (rand(899999) + 100000).to_s }
    avatar { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }

    factory :user_with_out_password do
      skip_password true
      # factory :employee do
      #   startup_link_verifier_id 1
      #   startup_verifier_token { SecureRandom.hex(30) }
      # end
      factory :founder do
        is_founder true
        startup_link_verifier_id 1
        startup_verifier_token { SecureRandom.hex(30) }
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
        designation { Faker::Lorem.word }
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

  factory :address do
    flat  "flat"
    building  "building"
    area  "area"
    town  "town"
    state "state"
    pin "pin"
  end

  factory :guardian do
    association :name, factory: :name, strategy: :build
    association :address, factory: :address, strategy: :build
  end

  factory :user_category, class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :user
  end

  factory :news_category,  class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :news
  end

  factory :event_category,  class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :event
  end

  factory :startup_category,  class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :startup
  end

  factory :news do |f|
    author
    association :category, factory: :news_category, strategy: :build
    f.title { Faker::Lorem.characters }
    f.body {Faker::Lorem.paragraph}
  end

  factory :location do |f|
    f.latitude { Faker::Number.number(8) }
    f.longitude { Faker::Number.number(8) }
    f.title { Faker::Lorem.characters }
    f.address { Faker::Lorem.paragraph }
  end

  factory :bank do |f|
    f.is_joint true
    startup
  end

  factory :connection do
    user
    contact
    direction Connection::DIRECTION_USER_TO_SV
  end

  factory :request  do
    association :user, factory: :founder
    body { Faker::Lorem.words(15).join ' ' }
  end

end
