require_relative 'helper'

after 'development:levels', 'development:cohorts', 'development:users' do
  puts 'Seeding founders'

  admin_user = User.find_by(email: 'admin@example.com')
  available_tags = admin_user.school.founder_tag_list.to_a

  admin_user
    .school
    .courses
    .each do |course|
      admin_user.founders.create!(
        cohort: course.cohorts.first,
        level: course.levels.first,
        tag_list: available_tags.sample(2)
      )
    end

  (1..200).each do |index|
    student_user = User.find_by(email: "student#{index}@example.com")
    available_tags = student_user.school.founder_tag_list.to_a
    student_user
      .school
      .courses
      .each do |course|
        student_user.founders.create!(
          cohort: course.cohorts.sample,
          level: course.levels.first,
          tag_list: available_tags.sample(2)
        )
      end
  end
end
