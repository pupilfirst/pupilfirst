require_relative 'helper'

after 'development:founders' do
  puts 'Seeding Applicants'

  Course.all.each do |course|
    (1..3).each do |index|
      Applicant.create!(
        name: Faker::Lorem.words(number: 3).join(' '),
        email: "applicant#{course.id}-#{index}@example.com",
        email_verified: true,
        course: course
      )
    end
  end
end
