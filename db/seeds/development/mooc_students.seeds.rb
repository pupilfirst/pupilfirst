require_relative 'helper'

puts 'Seeding mooc_students'

after 'development:states', 'development:users', 'development:colleges' do
  user = User.find_by(email: 'mooc_student@sv.co')
  college = College.find_by(name: 'Cochin University of Science and Technology, Kochi')

  MoocStudent.create!(
    email: 'mooc_student@sv.co',
    name: 'MOOC Student',
    college: college,
    semester: MoocStudent.valid_semester_values.sample,
    state: State.all.sample.name,
    gender: Founder.valid_gender_values.sample,
    user: user,
    phone: '9876543210'
  )
end
