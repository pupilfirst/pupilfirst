require_relative 'helper'

puts 'Seeding mooc_students'

after 'development:universities', 'development:states', 'development:users' do
  user = User.find_by(email: 'mooc_student@sv.co')

  MoocStudent.create!(
    email: 'mooc_student@sv.co',
    university: University.first,
    college: Faker::Lorem.words(2).join(' '),
    semester: MoocStudent.valid_semester_values.sample,
    state: State.all.sample.name,
    gender: Founder.valid_gender_values.sample,
    user: user,
    phone: '9876543210'
  )
end
