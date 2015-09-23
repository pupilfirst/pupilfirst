require_relative 'helper'

# Just a user.
User.create!(email: 'someone@mobme.in', fullname: 'Some One', password: 'password', password_confirmation: 'password', confirmed_at: Time.now)

# A user is to be a mentor.
User.create!(email: 'mentor@sv.co', fullname: 'Mentor User', password: 'password', password_confirmation: 'password', confirmed_at: Time.now)
