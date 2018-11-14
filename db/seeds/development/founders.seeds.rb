require_relative 'helper'

after 'development:colleges', 'development:startups' do
  puts 'Seeding founders'

  unfinished_swan = Startup.find_by(product_name: 'Unfinished Swan')

  # Seed an applicant.
  john_doe = User.create(email: 'johndoe@example.com')

  founder_john_doe = Founder.create!(
    name: 'John Doe',
    email: 'johndoe@example.com',
    phone: '9876543210',
    reference: Founder.reference_sources.sample,
    college: College.first,
    user: john_doe,
    startup: unfinished_swan
  )

  unfinished_swan.update!(team_lead: founder_john_doe)

  teams = {
    'Super Product' => [
      [true, 'someone@sv.co', 'Some One', 20.years.ago, Founder::GENDER_MALE, 9876543210],
      [false, 'thedude@sv.co', 'Big Lebowski', 40.years.ago, Founder::GENDER_MALE, 9000000000],
      [false, 'thirdgal@sv.co', 'Gal Third', 30.years.ago, Founder::GENDER_FEMALE, 9898989898]
    ],
    'The Avengers' => [
      [false, 'widow@example.org', 'Janet Dyne', 25.years.ago, Founder::GENDER_FEMALE, 9222222222],
      [true, 'ironman@example.org', 'Anthony Edward Tony Stark', 40.years.ago, Founder::GENDER_MALE, 9333333333],
      [false, 'hulk@example.org', 'Robert Banner', 35.years.ago, Founder::GENDER_MALE, 9444444444],
      [false, 'thor@example.org', 'Thor Odinson', 30.years.ago, Founder::GENDER_MALE, 9555555555]
    ],
    'Justice League' => [
      [false, 'superman@example.org', 'Superman', 25.years.ago, Founder::GENDER_FEMALE, 9666666666],
      [true, 'batman@example.org', 'Batman', 26.years.ago, Founder::GENDER_MALE, 9777777777]
    ],
    'Guardians of the Galaxy' => [
      [false, 'groot@example.org', 'Groot', 25.years.ago, Founder::GENDER_FEMALE, 9888888888],
      [true, 'rocket@example.org', 'Rocket Raccoon', 24.years.ago, Founder::GENDER_MALE, 9999999999]
    ],
    'iOS Startup' => [
      [true, 'ios@example.org', 'iOS Guy', 25.years.ago, Founder::GENDER_MALE, 9876543200]
    ]
  }

  image_path = File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg'))

  teams.each do |team_name, founders|
    founders.each do |team_lead, email, name, born_on, gender, phone|
      user = User.where(email: email).first_or_create!

      startup = Startup.find_by(product_name: team_name)

      founder = Founder.create!(
        email: email,
        user: user,
        name: name,
        born_on: born_on,
        gender: gender,
        phone: phone,
        roles: Founder.valid_roles.sample([1, 2].sample),
        communication_address: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n"),
        identification_proof: File.open(image_path),
        startup: startup
      )

      startup.update!(team_lead: founder) if team_lead
    end
  end
end
