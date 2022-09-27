require_relative 'helper'

after 'development:courses' do
  puts 'Seeding faculty'

  school = School.first

  admin = User.find_by(email: 'admin@example.com')

  admin_coach =
    Faculty.create!(
      school: school,
      category: 'team',
      user: admin,
      public: false
    )

  school.courses.each_with_index do |course, index|
    user = User.find_by(email: "coach#{index + 1}@example.com")
    new_coach =
      Faculty.create!(
        school: school,
        category: 'team',
        user: user,
        public: true
      )

    # Add the new coach to the course.
    course.cohorts.each do |cohort|
      FacultyCohortEnrollment.create!(faculty: new_coach, cohort: cohort)
    end

    # Add admin@example.com as a coach for every course.
    course.cohorts.each do |cohort|
      FacultyCohortEnrollment.create!(faculty: admin_coach, cohort: cohort)
    end
  end
end
