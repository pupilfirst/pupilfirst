require_relative 'helper'

puts 'Seeding course_modules'

CourseModule.create!(
  name: 'Introduction',
  module_number: 1,
  publish_at: 4.week.ago
)

CourseModule.create!(
  name: 'Why Should You Start In College?',
  module_number: 2,
  publish_at: 3.weeks.ago
)

CourseModule.create!(
  name: 'What are Startups?',
  module_number: 3,
  publish_at: 1.week.ago
)

CourseModule.create!(
  name: 'Startup Roles',
  module_number: 4,
  publish_at: 1.day.ago
)
