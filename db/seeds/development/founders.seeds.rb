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
