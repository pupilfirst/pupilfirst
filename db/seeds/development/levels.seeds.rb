require_relative 'helper'

after 'development:courses' do
  puts 'Seeding levels'

  startup_course = Course.find_by(name: 'Startup')
  developer_course = Course.find_by(name: 'Developer')
  vr_course = Course.find_by(name: 'VR')
  ios_course = Course.find_by(name: 'iOS')

  Level.create!(number: 0, name: 'Admissions', course: startup_course)
  Level.create!(number: 1, name: 'Research', course: startup_course)
  Level.create!(number: 2, name: 'Wireframe', unlock_on: 1.month.ago, course: startup_course)
  Level.create!(number: 3, name: 'Prototype', unlock_on: 2.month.from_now, course: startup_course)
  Level.create!(number: 4, name: 'Launch', unlock_on: 3.month.from_now, course: startup_course)
  Level.create!(number: 1, name: 'Planning', course: developer_course)
  Level.create!(number: 2, name: 'Design', course: developer_course)
  Level.create!(number: 3, name: 'Implementation', course: developer_course)
  Level.create!(number: 4, name: 'Testing', course: developer_course)
  Level.create!(number: 1, name: 'New Realities', course: vr_course)
  Level.create!(number: 2, name: 'Keep it Virtual', course: vr_course)
  Level.create!(number: 3, name: 'Materials and Meshes', course: vr_course)
  Level.create!(number: 4, name: 'VR-Design', course: vr_course)
  Level.create!(number: 1, name: 'iOS First Level', course: ios_course)
  Level.create!(number: 2, name: 'iOS Second Level', course: ios_course)
end
