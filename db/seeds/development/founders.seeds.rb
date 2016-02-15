require_relative 'helper'

# Just a user.
Founder.create!(email: 'someone@mobme.in', first_name: 'Some', last_name: 'One', password: 'password', password_confirmation: 'password', confirmed_at: Time.now, born_on: 20.years.ago, gender: 'male')
