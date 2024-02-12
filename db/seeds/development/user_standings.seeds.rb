after "development:standings", "development:users" do
  puts "Seeding user standings"

  creator = User.first
  school = School.find_by(name: "Test School")
  user_1 = school.users.find_by(email: "student1@example.com")

  user_1.user_standings.create!(
    standing: Standing.second,
    reason: Faker::Lorem.sentence,
    creator: creator
  )

  user_1.user_standings.create!(
    standing: Standing.last,
    reason: Faker::Lorem.sentence,
    creator: creator
  )

  user_2 = school.users.find_by(email: "student2@example.com")

  user_2.user_standings.create!(
    standing: Standing.second,
    reason: Faker::Lorem.sentence,
    creator: creator
  )

  user_2.user_standings.create!(
    standing: Standing.last,
    reason: Faker::Lorem.sentence,
    creator: creator
  )

  user_3 = school.users.find_by(email: "student3@example.com")

  user_3.user_standings.create!(
    standing: Standing.second,
    reason: Faker::Lorem.sentence,
    creator: creator
  )
end
