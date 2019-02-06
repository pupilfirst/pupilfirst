require_relative 'helper'

after 'development:colleges', 'development:startups' do
  puts 'Seeding founders'

  # Seed an applicant.
  john_doe = User.create(email: 'johndoe@example.com')

  john_doe_attributes = {
    name: 'John Doe',
    phone: '9876543210',
    reference: Founder.reference_sources.sample,
    college: College.first,
    user: john_doe,
  }

  # Add John Doe to teams in all three courses.
  ['Guardians of the Galaxy', 'iOS Startup'].each do |team_name|
    startup = Startup.find_by(product_name: team_name)

    founder_john_doe = Founder.create!(john_doe_attributes.merge(
      startup: startup
    ))
  end

  teams = {
    'Super Product' => [
      ['someone@sv.co', 'Some One', 20.years.ago, Founder::GENDER_MALE, 9876543210],
      ['thedude@sv.co', 'Big Lebowski', 40.years.ago, Founder::GENDER_MALE, 9000000000],
      ['thirdgal@sv.co', 'Gal Third', 30.years.ago, Founder::GENDER_FEMALE, 9898989898]
    ],
    'The Avengers' => [
      ['widow@example.org', 'Janet Dyne', 25.years.ago, Founder::GENDER_FEMALE, 9222222222],
      ['ironman@example.org', 'Anthony Edward Tony Stark', 40.years.ago, Founder::GENDER_MALE, 9333333333],
      ['hulk@example.org', 'Robert Banner', 35.years.ago, Founder::GENDER_MALE, 9444444444],
      ['thor@example.org', 'Thor Odinson', 30.years.ago, Founder::GENDER_MALE, 9555555555]
    ],
    'Justice League' => [
      ['superman@example.org', 'Superman', 25.years.ago, Founder::GENDER_FEMALE, 9666666666],
      ['batman@example.org', 'Batman', 26.years.ago, Founder::GENDER_MALE, 9777777777]
    ],
    'Guardians of the Galaxy' => [
      ['groot@example.org', 'Groot', 25.years.ago, Founder::GENDER_FEMALE, 9888888888],
      ['rocket@example.org', 'Rocket Raccoon', 24.years.ago, Founder::GENDER_MALE, 9999999999]
    ],
    'iOS Startup' => [
      ['ios@example.org', 'iOS Guy', 25.years.ago, Founder::GENDER_MALE, 9876543200]
    ]
  }

  teams.each do |team_name, founders|
    startup = Startup.find_by(product_name: team_name)

    founders.each do |email, name, born_on, gender, phone|
      user = User.where(email: email).first_or_create!

      Founder.create!(
        user: user,
        name: name,
        born_on: born_on,
        gender: gender,
        phone: phone,
        roles: Founder.valid_roles.sample([1, 2].sample),
        communication_address: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n"),
        startup: startup
      )
    end
  end
end
