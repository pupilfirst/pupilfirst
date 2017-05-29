puts 'Seeding course_modules (idempotent)'

CourseModule.where(module_number: 1).first_or_create!(
  name: 'Introduction',
  publish_at: 4.week.ago
)

CourseModule.where(module_number: 2).first_or_create!(
  name: 'Why Should You Start In College?',
  publish_at: 3.weeks.ago
)

CourseModule.where(module_number: 3).first_or_create!(
  name: 'What are Startups?',
  publish_at: 1.week.ago
)

CourseModule.where(module_number: 4).first_or_create!(
  name: 'Startup Roles',
  publish_at: 1.day.ago
)
