require_relative "helper"

after "development:levels", "development:cohorts", "development:users" do
  puts "Seeding students"

  admin_user = User.find_by(email: "admin@example.com")
  available_tags = admin_user.school.student_tag_list.to_a

  admin_user.school.courses.each do |course|
    admin_user.students.create!(
      cohort: course.cohorts.first,
      tag_list: available_tags.sample(2)
    )
  end

  (1..200).each do |index|
    student_user = User.find_by(email: "student#{index}@example.com")
    available_tags = student_user.school.student_tag_list.to_a
    student_user.school.courses.each do |course|
      student_user.students.create!(
        cohort: course.cohorts.sample,
        tag_list: available_tags.sample(2)
      )
    end
  end
end
