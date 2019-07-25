require_relative 'helper'

after 'development:faculty' do
  puts 'Seeding course authors'

  user = Faculty.first.user

  School.first.courses.each do |course|
    CourseAuthor.create!(user: user, course: course)
  end
end
