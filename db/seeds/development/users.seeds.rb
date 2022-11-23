require_relative 'helper'

after 'development:organisations' do
  puts 'Seeding users'

  # Add admin user to all schools.
  School.all.each do |school|
    user =
      school
        .users
        .where(email: 'admin@example.com')
        .first_or_create!(name: Faker::Name.name, title: 'School Admin')

    user.tag_list = %w[admin]
    user.save!
  end

  # Add several hundred student users in the first school.
  school = School.find_by(name: 'Test School')

  (1..200).each do |index|
    school.users.create!(
      email: "student#{index}@example.com",
      name: Faker::Name.name,
      title: 'Student',
      tag_list: %w[student],
      organisation: school.organisations.sample
    )
  end

  # Add two users to be coaches in first school.
  (1..2).each do |index|
    school.users.create!(
      email: "coach#{index}@example.com",
      name: Faker::Name.name,
      title: Faker::Job.title,
      tag_list: %w[coach]
    )
  end

  # Add a few users in the second school.
  second_school = School.find_by(name: 'Second School')

  (1..2).each do |index|
    second_school.users.create!(
      email: "second_school_user#{index}@example.com",
      name: Faker::Name.name,
      title: Faker::Job.title,
      organisation: second_school.organisations[index - 1]
    )
  end
end
