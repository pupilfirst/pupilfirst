require_relative 'helper'

after 'development:schools' do

  puts 'Seeding levels'
  startup_school = School.find_by(name: 'Startup School')
  developer_school = School.find_by(name: 'Developer School')
  Level.create!(number: 0, name: 'Admissions', school: startup_school)
  Level.create!(number: 1, name: 'Research', school: startup_school)
  Level.create!(number: 2, name: 'Wireframe', unlock_on: 1.month.from_now, school: startup_school)
  Level.create!(number: 3, name: 'Prototype', unlock_on: 2.month.from_now, school: startup_school)
  Level.create!(number: 4, name: 'Launch', unlock_on: 3.month.from_now, school: startup_school)
  Level.create!(number: 0, name: 'Admissions', school: developer_school)
  Level.create!(number: 1, name: 'Research', school: developer_school)

end