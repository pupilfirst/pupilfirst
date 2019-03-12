require_relative 'helper'

after 'development:colleges', 'development:startups' do
  puts 'Seeding founders'

  # Seed an applicant.
  john_doe = User.create(email: 'johndoe@example.com')

  john_doe_attributes = {
    name: 'John Doe',
    phone: '9876543210',
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
      ['someone@sv.co', 'Some One', Founder::GENDER_MALE, 9876543210],
      ['thedude@sv.co', 'Big Lebowski', Founder::GENDER_MALE, 9000000000],
      ['thirdgal@sv.co', 'Gal Third', Founder::GENDER_FEMALE, 9898989898]
    ],
    'The Avengers' => [
      ['widow@example.org', 'Janet Dyne', Founder::GENDER_FEMALE, 9222222222],
      ['ironman@example.org', 'Anthony Edward Tony Stark', Founder::GENDER_MALE, 9333333333],
      ['hulk@example.org', 'Robert Banner', Founder::GENDER_MALE, 9444444444],
      ['thor@example.org', 'Thor Odinson', Founder::GENDER_MALE, 9555555555]
    ],
    'Justice League' => [
      ['superman@example.org', 'Superman', Founder::GENDER_FEMALE, 9666666666],
      ['batman@example.org', 'Batman', Founder::GENDER_MALE, 9777777777]
    ],
    'Guardians of the Galaxy' => [
      ['groot@example.org', 'Groot', Founder::GENDER_FEMALE, 9888888888],
      ['rocket@example.org', 'Rocket Raccoon', Founder::GENDER_MALE, 9999999999]
    ],
    'iOS Startup' => [
      ['ios@example.org', 'iOS Guy', Founder::GENDER_MALE, 9876543200]
    ],
    'iOS Startup 2' => [
      ['ios_s2@example.org', 'iOS Guy s2', Founder::GENDER_MALE, 9876543300]
    ],
    'iOS Guy 2' => [
      ['ios2@example.org', 'iOS Guy 2', Founder::GENDER_FEMALE, 9876543400]
    ],
    'iOS Guy 3' => [
      ['ios3@example.org', 'iOS Guy 3', Founder::GENDER_MALE, 9876543500]
    ],
  'School Admin' => [
    ['admin@example.com', 'Test Profile', Founder::GENDER_MALE, 9876543500]
  ]
  }

  teams.each do |team_name, founders|
    startup = Startup.find_by(product_name: team_name)

    founders.each do |email, name, gender, phone|
      user = User.where(email: email).first_or_create!

      Founder.create!(
        user: user,
        name: name,
        gender: gender,
        phone: phone,
        roles: Founder.valid_roles.sample([1, 2].sample),
        communication_address: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n"),
        startup: startup
      )
    end
  end
end
