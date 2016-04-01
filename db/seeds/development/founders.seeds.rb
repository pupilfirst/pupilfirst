require_relative 'helper'

MALE = Founder::GENDER_MALE
FEMALE = Founder::GENDER_FEMALE
OTHER = Founder::GENDER_OTHER

# 3 random founders for sv.co
founders_list = [
  ['someone@sv.co', 'Some', 'One', 20.years.ago, MALE],
  ['thedude@sv.co', 'Big', 'Lebowski', 40.years.ago, MALE],
  ['thirdguy@sv.co', 'Guy', 'Third', 30.years.ago, FEMALE]
]

# 5 more founders for avengers
founders_list += [
  ['ultron@avengers.co', 'HenryJonathan', 'Pym', 40.years.ago, MALE],
  ['wasp@avengers.co', 'Janet', 'Dyne', 25.years.ago, FEMALE],
  ['ironman@avengers.co', 'AnthonyEdward', 'TonyStark', 40.years.ago, MALE],
  ['hulk@avengers.co', 'Robert', 'Banner', 35.years.ago, MALE],
  ['thor@avengers.co', 'Thor', 'Odinson', 30.years.ago, MALE]
]

founders_list.each do |email, first_name, last_name, born_on, gender|
  Founder.create!(email: email, first_name: first_name, last_name: last_name, password: 'password',
    password_confirmation: 'password', confirmed_at: Time.now, born_on: born_on, gender: gender
  )
end
