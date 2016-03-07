require_relative 'helper'

# 'The' founder.
Founder.create!(
  email: 'someone@sv.co',
  first_name: 'Some',
  last_name: 'One',
  password: 'password',
  password_confirmation: 'password',
  confirmed_at: Time.now,
  born_on: 20.years.ago,
  gender: Founder::GENDER_MALE
)

# A second co-founder
Founder.create!(
  email: 'thedude@sv.co',
  first_name: 'Big',
  last_name: 'Lebowski',
  password: 'password',
  password_confirmation: 'password',
  confirmed_at: Time.now,
  born_on: 40.years.ago,
  gender: Founder::GENDER_MALE
)

# and a third one
Founder.create!(
  email: 'thirdguy@sv.co',
  first_name: 'Guy',
  last_name: 'Third',
  password: 'password',
  password_confirmation: 'password',
  confirmed_at: Time.now,
  born_on: 30.years.ago,
  gender: Founder::GENDER_MALE
)
