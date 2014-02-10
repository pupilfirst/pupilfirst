# This will guess the User class

include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :admin_user, aliases: [:author] do
    fullname { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    username  { Faker::Name.first_name }
    email 		{ Faker::Internet.email }
    password  "password"
    password_confirmation "password"
  end

  factory :user, aliases: [:founder] do
    fullname { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    username  { Faker::Lorem.characters(9) }
    email 		{ Faker::Internet.email }
    skip_password true
  end

	factory :startup_application do |f|
		f.name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
		f.email { Faker::Internet.email }
		f.phone { Faker::PhoneNumber.phone_number}
		f.idea { Faker::Lorem.paragraph }
		f.website {Faker::Internet.domain_name}
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

	factory :event do |f|
		start_at = ::Time.now + ::Random.rand(1000)
    f.title 				{ Faker::Lorem.characters }
    f.description 	{ Faker::Lorem.paragraph }
    # f.picture Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/example.jpg')))
		f.picture { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    f.start_at start_at
    f.end_at (start_at + ::Random.rand(1000))

    location
		author
		association :category, factory: :event_category, strategy: :build
	end

	factory :startup do |f|
		f.name 			{Faker::Lorem.characters(20)}
		f.logo { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
		f.pitch 		{Faker::Lorem.words(6).join(' ')}
		f.about 		{Faker::Lorem.paragraph(7)}
		f.website   {Faker::Internet.domain_name}
		f.email 		{Faker::Internet.email}
		f.phone  	{Faker::PhoneNumber.cell_phone}
		f.founders {[create(:founder), create(:founder)]}
		f.category_ids {[create(:startup_category).id]}
  end
end
