# This will guess the User class
FactoryGirl.define do
  factory :user, aliases: [:author] do
    fullname "John Doe"
    username  "Doe"
    email 		"foo@bar.com"
  end

	factory :startup_application do |f|
		f.name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
		f.email { Faker::Internet.email }
		f.phone { Faker::PhoneNumber.phone_number}
		f.idea { Faker::Lorem.paragraph }
		f.website {Faker::Internet.domain_name}
	end

	factory :news_category,  class: Category do |f|
		f.name "News Category"
		f.category_type :news
	end

	factory :event_category,  class: Category do |f|
		f.name "News Category"
		f.category_type :event
	end

	factory :news do |f|
		author
		association :category, factory: :news_category, strategy: :build
		f.title { Faker::Lorem.characters }
		f.body {Faker::Lorem.paragraph}
	end
end
