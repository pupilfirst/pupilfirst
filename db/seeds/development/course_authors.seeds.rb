require_relative 'helper'

after 'development:faculty' do
  puts 'Seeding course_authors'

  # Create course authors for a user who is not a school admin
  user = User.where(email: 'coach2@example.com').first

  School.first.courses.each do |course|
    CourseAuthor.create!(user: user, course: course)
  end
end
