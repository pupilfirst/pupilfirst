require_relative 'helper'

after 'development:schools' do
  puts 'Seeding levels'

  startup_school = School.find_by(name: 'Startup')
  developer_school = School.find_by(name: 'Developer')
  vr_school = School.find_by(name: 'VR')

  Level.create!(number: 0, name: 'Admissions', school: startup_school)
  Level.create!(number: 1, name: 'Research', school: startup_school)
  Level.create!(number: 2, name: 'Wireframe', unlock_on: 1.month.from_now, school: startup_school)
  Level.create!(number: 3, name: 'Prototype', unlock_on: 2.month.from_now, school: startup_school)
  Level.create!(number: 4, name: 'Launch', unlock_on: 3.month.from_now, school: startup_school)
  Level.create!(number: 1, name: 'Planning', school: developer_school)
  Level.create!(number: 2, name: 'Design', school: developer_school)
  Level.create!(number: 3, name: 'Implementation', school: developer_school)
  Level.create!(number: 4, name: 'Testing', school: developer_school)
  Level.create!(number: 1, name: 'New Realities', school: vr_school)
  Level.create!(number: 2, name: 'Keep it Virtual', school: vr_school)
  Level.create!(number: 3, name: 'Materials and Meshes', school: vr_school)
  Level.create!(number: 4, name: 'VR-Design', school: vr_school)
end
