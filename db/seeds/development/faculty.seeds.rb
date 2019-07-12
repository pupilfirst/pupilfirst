require_relative 'helper'

after 'development:courses' do
  puts 'Seeding faculty'

  school = School.first

  admin = User.find_by(email: 'admin@example.com')

  admin_coach = Faculty.create!(
    school: school,
    category: 'team',
    user: admin,
    public: false
  )

  school.courses.each_with_index do |course, index|
    user = User.find_by(email: "coach#{index + 1}@example.com")
    new_coach = Faculty.create!(school: school, category: 'team', user: user, public: true)

    # Add the new coach to the course.
    FacultyCourseEnrollment.create!(safe_to_create: true, faculty: new_coach, course: course)

    # Add admin@example.com as a coach for every course.
    FacultyCourseEnrollment.create!(safe_to_create: true, faculty: admin_coach, course: course)
  end
end
