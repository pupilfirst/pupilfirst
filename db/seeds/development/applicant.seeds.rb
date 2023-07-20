require_relative 'helper'

after 'development:students' do
  puts 'Seeding Applicants'

  Course.all.each do |course|
    (1..3).each do |index|
      course.applicants.create!(
        name: Faker::Lorem.words(number: 3).join(' '),
        email: "applicant#{course.id}-#{index}@example.com",
        email_verified: true
      )
    end
  end
end
