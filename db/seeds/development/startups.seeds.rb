require_relative 'helper'

after 'development:levels' do
  puts 'Seeding startups'

  # Load levels.
  startup_course_level_1 = Level.find_by(name: 'Wireframe')
  developer_course_level_1 = Level.find_by(name: 'Planning')
  vr_course_level_1 = Level.find_by(name: 'New Realities')
  ios_course_level_1 = Level.find_by(name: 'iOS First Level')
  ios_course_level_2 = Level.find_by(name: 'iOS Second Level')

  # Startup with live agreement.
  Startup.create!(
    level: startup_course_level_1,
    name: 'Super Product',
  )

  # A second 'Avengers' startup.
  Startup.create!(
    level: startup_course_level_1,
    name: 'The Avengers'
  )

  # Third startup 'Justice League' for developer course
  Startup.create!(
    level: developer_course_level_1,
    name: 'Justice League'
  )

  # Fourth startup 'Guardians of the Galaxy' for VR course
  Startup.create!(
    level: vr_course_level_1,
    name: 'Guardians of the Galaxy'
  )

  ['iOS Guy 2', 'iOS Guy 3'].each do |startup_name|
    Startup.create!(
      name: startup_name,
      level: ios_course_level_1
    )
  end

  ['iOS Startup', 'iOS Startup 2'].each do |startup_name|
    Startup.create!(
      name: startup_name,
      level: ios_course_level_2
    )
  end

  # A startup for Admin in VR course
  Startup.create!(
    level: vr_course_level_1,
    name: 'School Admin'
  )
end
