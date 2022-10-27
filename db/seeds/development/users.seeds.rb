require_relative 'helper'

after 'development:organisations' do
  puts 'Seeding users'

  organisations = Organisation.all

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

  # Add three student users in the first school.
  school = School.first

  (1..200).each do |index|
    school.users.create!(
      email: "student#{index}@example.com",
      name: Faker::Name.name,
      title: 'Student',
      tag_list: %w[student],
      organisation: organisations.sample
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
end
