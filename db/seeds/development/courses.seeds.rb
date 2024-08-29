after "development:course_categories" do
  puts "Seeding courses"

  school = School.first

  def highlights
    {
      icon: Types::CourseHighlightInputType.allowed_icons.sample,
      title: Faker::Lorem.words(number: 2).join(" ").titleize,
      description: Faker::Lorem.paragraph
    }
  end

  2.times do
    course = school.courses.create!(
      name: Faker::Lorem.words(number: 2).join(" ").titleize,
      description: Faker::Lorem.paragraph,
      progression_limit: 1,
      highlights: [highlights, highlights, highlights, highlights],
      beckn_enabled: true
    )

    course.course_categories << school.course_categories.sample
  end
end
