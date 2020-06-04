require_relative 'helper'

after 'development:levels', 'development:users' do
  puts 'Seeding startups'

  admin_user = User.find_by(email: 'admin@example.com')
  available_tags = admin_user.school.founder_tag_list.to_a

  admin_user.school.courses.each do |course|
    Startup.create!(name: admin_user.name, level: course.levels.first)
  end

  (1..3).each do |index|
    student_user = User.find_by(email: "student#{index}@example.com")
    level = student_user.school.courses.first.levels.first
    Startup.create!(name: student_user.name, level: level, tag_list: available_tags.sample(2))
  end
end
