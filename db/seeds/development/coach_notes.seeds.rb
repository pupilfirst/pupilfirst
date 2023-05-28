require_relative 'helper'

after 'development:timeline_events', 'development:faculty' do
  puts 'Seeding coach notes'

  school = School.find_by(name: 'Test School')
  user = school.users.find_by(email: 'student1@example.com')
  coach_user = school.users.joins(:faculty).first

  # Get the student entry with submissions.
  student = user.students.joins(:timeline_events).first

  student.coach_notes.create!(
    author: coach_user,
    note: 'This is a single-line note.'
  )

  student.coach_notes.create!(
    author: coach_user,
    note: 'This is an archived note, and should not be listed anywhere.',
    archived_at: 1.day.ago
  )

  student.coach_notes.create!(
    author: coach_user,
    note:
      "This is a multi-line note that uses Markdown.\n\n#{Faker::Markdown.sandwich}"
  )
end
