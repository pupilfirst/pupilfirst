after 'development:courses' do
  require_relative 'helper'

  puts 'Seeding faculty'

  faculty = Faculty.create!(
    name: 'Sanjay Vijayakumar',
    title: 'CEO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    sort_index: 1,
    user: User.create(email: 'mickeymouse@example.com')
  )
  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'Startup')
  )

  faculty = Faculty.create!(
    name: 'Vishnu Gopal',
    title: 'CTO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/minnie_mouse.jpg').open,
    sort_index: 2,
    user: User.create(email: 'minniemouse@example.com')
  )
  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'Developer')
  )

  faculty = Faculty.create!(
    name: 'Gautham',
    title: 'COO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'developer_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/donald_duck.jpg').open,
    sort_index: 3,
    user: User.create(email: 'donaldduck@example.com')
  )
  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'Startup')
  )

  faculty = Faculty.create!(
    name: 'Hari Gopal',
    title: 'Engineering Lead',
    key_skills: 'Looting, pillaging, etc.',
    category: 'visiting_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/jack_sparrow.png').open,
    user: User.create(email: 'goofy@example.com')
  )
  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'VR')
  )

  faculty = Faculty.create!(
    name: 'iOS Coach',
    title: 'Coaching Expert',
    category: 'developer_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    user: User.create(email: 'ioscoach@example.com')
  )
  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'iOS')
  )
end