after "development:schools" do
  puts "Seeding standings"

  school = School.first

  # create a default standing for school
  Standing.create!(
    name: "Normal",
    color: Faker::Color.hex_color,
    description: Faker::Lorem.sentence,
    school: school,
    default: true
  )

  # create non-default standings for school
  Standing.create!(
    name: "Poor",
    color: Faker::Color.hex_color,
    description: Faker::Lorem.sentence,
    school: school,
    default: false
  )

  Standing.create!(
    name: "Good",
    color: Faker::Color.hex_color,
    description: Faker::Lorem.sentence,
    school: school,
    default: false
  )

  Standing.create!(
    name: "Great",
    color: Faker::Color.hex_color,
    description: Faker::Lorem.sentence,
    school: school,
    default: false
  )
end
