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

  factory :social_id do
    social_id 			{Faker::Number.number(8)}
    social_token		{Faker::Lorem.characters(256)}
    permission			[]
    # association :user, factory: :user_with_out_password, strategy: :build
    factory :facebook_social_id do
    	provider :facebook
    	primary  true
    end
  end

  factory :user do
    fullname { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    username  { Faker::Lorem.characters(9) }
    salutation { ['Mr', 'Miss', 'Mrs'].shuffle.first }
    email 		{ Faker::Internet.email }
    born_on 	{ Date.current.to_s }
		avatar { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    factory :user_with_out_password do
	    skip_password true
      factory :employee do
        startup_link_verifier_id 1
        startup_verifier_token { SecureRandom.hex(30) }
      end
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

  factory :director, parent: :founder do
    pan   "pan"
    din   "din"
    aadhaar    "aadhaar"
    current_occupation  :current_occupation
    educational_qualification  :educational_qualification
    place_of_birth  :place_of_birth
    association :address, factory: :address, strategy: :build
    association :father, factory: :name, strategy: :build
    mother_maiden_name    "mother_maiden_name"
    married   true
    religion    "religion"
    association :guardian, factory: :guardian, strategy: :build
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

  factory :startup_village_help_category,  class: Category do |f|
    f.name {Faker::Lorem.words(2).join(' ')}
    f.category_type :startup_village_help
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
    f.name      {Faker::Lorem.characters(20)}
    f.logo { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    f.pitch     {Faker::Lorem.words(6).join(' ')}
    f.address     {Faker::Lorem.words(6).join(' ')}
    f.about     {Faker::Lorem.paragraph(7)}
    f.website   {Faker::Internet.domain_name}
    f.email     {Faker::Internet.email}
    f.phone   {Faker::PhoneNumber.cell_phone}
    f.help_from_sv   {
      FactoryGirl.create(:startup_village_help_category)
      FactoryGirl.create(:startup_village_help_category)
      Category.startup_village_help.map(&:id).shuffle[0..2]
    }
    # f.founders {[create(:founder), create(:founder)]}
    # f.category_ids {[create(:startup_category).id]}
    after(:build) do |startup|
      startup.founders << create(:founder, startup: startup)
      startup.founders << create(:founder, startup: startup)
      startup.categories << create(:startup_category)
    end
  end

  factory :startup_application, class: Startup do |f|
    f.name      {Faker::Lorem.characters(20)}
    f.pitch     {Faker::Lorem.words(6).join(' ')}
    f.website   {Faker::Internet.domain_name}
    f.phone   {Faker::PhoneNumber.cell_phone}
  end

  factory :incorporation, class: Startup do |f|
    f.dsc "dsc"
    f.company_names [{name: 'company1', description: 'desc'}]
    f.authorized_capital  "authorized_capital"
    f.share_holding_pattern "share_holding_pattern"
    f.moa "moa"
    f.police_station  "police_station"
  end

  factory :bank do |f|
    f.is_joint true
    startup
  end
end
