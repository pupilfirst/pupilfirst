after 'development:courses' do
  puts 'Seeding cohorts'

  school = School.first

  def highlights
    {
      icon: Types::CourseHighlightInputType.allowed_icons.sample,
      title: Faker::Lorem.words(number: 2).join(' ').titleize,
      description: Faker::Lorem.paragraph
    }
  end

  school.courses.each do |course|
    course.cohorts.create!(
      name: "Summer #{Time.zone.now.year}",
      description: Faker::Lorem.paragraph,
      course: course
    )
    course.update!(default_cohort: course.cohorts.first)

    course.cohorts.create!(
      name: "Winter #{Time.zone.now.year}",
      description: Faker::Lorem.paragraph,
      course: course,
      ends_at: 1.day.ago
    )
  end
end
