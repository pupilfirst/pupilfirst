require_relative 'helper'

# Just a user.
User.create!(email: 'someone@mobme.in', first_name: 'Some', last_name: 'One', password: 'password', password_confirmation: 'password', confirmed_at: Time.now, born_on: 20.years.ago, gender: 'male')

# A user is to be a mentor.
User.create!(email: 'mentor@sv.co', first_name: 'Mentor', last_name: 'User', password: 'password', password_confirmation: 'password', confirmed_at: Time.now, born_on: 20.years.ago, gender: 'male')
