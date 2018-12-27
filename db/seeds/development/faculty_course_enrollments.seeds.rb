after 'development:courses', 'development:faculty' do
  puts 'Seeding faculty_course_enrollments (idempotent)'

  school_admin = User.find_by(email: 'admin@example.com').faculty

  Course.all.each do |course|
    FacultyCourseEnrollment.where(course: course, faculty: school_admin).first_or_create!(safe_to_create: true)
  end
end
