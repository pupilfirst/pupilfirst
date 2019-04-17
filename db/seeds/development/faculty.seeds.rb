after 'development:courses' do
  require_relative 'helper'

  puts 'Seeding faculty'

  sv = School.find_by(name: 'SV.CO')

  sanjay = User.create(email: 'mickeymouse@example.com')

  UserProfile.create!(
    user: sanjay,
    school: sv,
    name: 'Sanjay Vijayakumar',
    title: 'CEO',
    linkedin_url: 'https://linkedin.com'
  )

  faculty = Faculty.create!(
    key_skills: Faker::Lorem.words(3).join(', '),
    category: 'team',
    sort_index: 1,
    user: sanjay,
    school: sv,
    public: true
  )

  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'Startup')
  )


  vishnu = User.create(email: 'minniemouse@example.com')

  UserProfile.create!(
    user: vishnu,
    school: sv,
    name: 'Vishnu Gopal',
    title: 'CTO',
    linkedin_url: 'https://linkedin.com',

  )

  faculty = Faculty.create!(
    key_skills: Faker::Lorem.words(3).join(', '),
    category: 'team',
    sort_index: 2,
    user: vishnu,
    school: sv,
    public: true
  )

  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'Developer')
  )

  gautham = User.create(email: 'donaldduck@example.com')

  UserProfile.create!(
    user: gautham,
    school: sv,
    name: 'Gautham',
    title: 'COO',
    linkedin_url: 'https://linkedin.com',
  )

  faculty = Faculty.create!(
    key_skills: Faker::Lorem.words(3).join(', '),
    category: 'developer_coaches',
    sort_index: 3,
    user: gautham,
    school: sv,
    public: true
  )

  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'Startup')
  )

  hari = User.create(email: 'goofy@example.com')

  UserProfile.create!(
    user: hari,
    school: sv,
    name: 'Hari Gopal',
    title: 'Engineering Lead',
  )

  faculty = Faculty.create!(
    key_skills: 'Looting, pillaging, etc.',
    category: 'visiting_coaches',
    user: hari,
    school: sv,
    public: true
  )

  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'VR')
  )

  ios_coach = User.create(email: 'ioscoach@example.com')

  UserProfile.create!(
    user: ios_coach,
    school: sv,
    name: 'iOS Coach',
    title: 'Coaching Expert',
    about: "This is just a demo coach. The about field is required for Faculty#show to be available - that's why this text is here.",
  )

  faculty = Faculty.create!(
    category: 'vr_coaches',
    user: ios_coach,
    school: sv,
    public: true
  )

  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: faculty,
    course: Course.find_by(name: 'iOS')
  )

  admin = User.find_by(email: 'admin@example.com')

  UserProfile.create!(
    user: admin,
    school: sv,
    name: 'School Admin',
    title: 'School Admin',
  )

  admin_coach = Faculty.create!(
    category: 'team',
    user: admin,
    school: sv
  )

  # Enroll admin@example.com as coach on iOS and VR courses.
  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: admin_coach,
    course: Course.find_by(name: 'iOS')
  )

  FacultyCourseEnrollment.create!(
    safe_to_create: true,
    faculty: admin_coach,
    course: Course.find_by(name: 'VR')
  )
end
