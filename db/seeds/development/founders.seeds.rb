require_relative 'helper'

after 'development:startups' do
  puts 'Seeding founders'

  # Seed an applicant.
  john_doe = User.create(email: 'johndoe@example.com')

  UserProfile.create!(user: john_doe, school: School.first, name: 'John Doe', phone: '9876543210', title: "The Unknown")

  # Add John Doe to teams in all three courses.
  ['Guardians of the Galaxy', 'iOS Startup'].each do |team_name|
    startup = Startup.find_by(name: team_name)
    Founder.create!(user: john_doe, startup: startup)
  end

  teams = {
    'Super Product' => [
      ['someone@sv.co', 'Some One', UserProfile::GENDER_MALE, 9876543210],
      ['thedude@sv.co', 'Big Lebowski', UserProfile::GENDER_MALE, 9000000000],
      ['thirdgal@sv.co', 'Gal Third', UserProfile::GENDER_FEMALE, 9898989898]
    ],
    'The Avengers' => [
      ['widow@example.org', 'Janet Dyne', UserProfile::GENDER_FEMALE, 9222222222],
      ['ironman@example.org', 'Anthony Edward Tony Stark', UserProfile::GENDER_MALE, 9333333333],
      ['hulk@example.org', 'Robert Banner', UserProfile::GENDER_MALE, 9444444444],
      ['thor@example.org', 'Thor Odinson', UserProfile::GENDER_MALE, 9555555555]
    ],
    'Justice League' => [
      ['superman@example.org', 'Superman', UserProfile::GENDER_FEMALE, 9666666666],
      ['batman@example.org', 'Batman', UserProfile::GENDER_MALE, 9777777777]
    ],
    'Guardians of the Galaxy' => [
      ['groot@example.org', 'Groot', UserProfile::GENDER_FEMALE, 9888888888],
      ['rocket@example.org', 'Rocket Raccoon', UserProfile::GENDER_MALE, 9999999999]
    ],
    'iOS Startup' => [
      ['ios@example.org', Faker::Name.name, UserProfile::GENDER_MALE, 9876543200]
    ],
    'iOS Startup 2' => [
      ['ios_s2@example.org', Faker::Name.name, UserProfile::GENDER_MALE, 9876543300]
    ],
    'iOS Guy 2' => [
      ['ios2@example.org', Faker::Name.name, UserProfile::GENDER_FEMALE, 9876543400]
    ],
    'iOS Guy 3' => [
      ['ios3@example.org', Faker::Name.name, UserProfile::GENDER_MALE, 9876543500]
    ],
    'School Admin' => [
      ['admin@example.com', 'School Admin', UserProfile::GENDER_MALE, 9876543500]
    ]
  }

  teams.each do |team_name, founders|
    startup = Startup.find_by(name: team_name)

    founders.each do |email, name, gender, phone|
      user = User.where(email: email).first_or_create!
      UserProfile.where(user: user, school: startup.school).first_or_create!(
        name: name,
        gender: gender,
        phone: phone,
        communication_address: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")
      )

      Founder.create!(
        user: user,
        roles: Founder.valid_roles.sample([1, 2].sample),
        startup: startup
      )
    end
  end
end
