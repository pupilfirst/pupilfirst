require_relative 'helper'

puts 'Seeding founders'

# 3 random founders for sv.co
founders_list = [
  ['someone@sv.co', 'Some One', 20.years.ago, Founder::GENDER_MALE, 9876543210],
  ['thedude@sv.co', 'Big Lebowski', 40.years.ago, Founder::GENDER_MALE],
  ['thirdgal@sv.co', 'Gal Third', 30.years.ago, Founder::GENDER_FEMALE]
]

# 5 more founders for avengers
founders_list += [
  ['ultron@avengers.co', 'Henry Jonathan Pym', 40.years.ago, Founder::GENDER_MALE],
  ['wasp@avengers.co', 'Janet Dyne', 25.years.ago, Founder::GENDER_FEMALE],
  ['ironman@avengers.co', 'Anthony Edward Tony Stark', 40.years.ago, Founder::GENDER_MALE],
  ['hulk@avengers.co', 'Robert Banner', 35.years.ago, Founder::GENDER_MALE],
  ['thor@avengers.co', 'Thor Odinson', 30.years.ago, Founder::GENDER_MALE]
]

founders_list.each do |email, name, born_on, gender, phone|
  # Don't recreate entries.
  next if Founder.find_by(email: email).present?

  user = User.where(email: email).first_or_create!

  Founder.create!(
    email: email,
    user: user,
    name: name,
    confirmed_at: Time.now,
    born_on: born_on,
    gender: gender,
    phone: phone
  )
end
