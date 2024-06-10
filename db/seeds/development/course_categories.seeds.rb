after "development:schools" do
  puts "Seeding course categories"

  school = School.first

  2.times do
    school.course_categories.create!(
      name: Faker::Lorem.words(number: 2).join(" ").titleize
    )
  end
end
