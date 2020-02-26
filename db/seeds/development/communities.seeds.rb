after 'development:schools', 'development:founders', 'development:faculty', 'development:courses' do
  puts 'Seeding communities'

  school = School.first
  course = Course.first

  community = school.communities.create!(name: Faker::Lorem.words(number: 2).join(' ').titleize, target_linkable: true)
  CommunityCourseConnection.create!(course: course, community: community)
end
