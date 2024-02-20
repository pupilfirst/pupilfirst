after "development:timeline_events" do
  puts "Seeding submission comments"

  school = School.find_by(name: "Test School")
  user = school.users.find_by(email: "student1@example.com")
  student = user.students.first
  user_2 = school.users.where.not(id: user.id).first

  TimelineEventOwner
    .where(student: student)
    .each do |event_owner|
      event_owner.timeline_event.submission_comments.create!(
        user: user_2,
        comment: "This is great!"
      )
      event_owner.timeline_event.submission_comments.create!(
        user: user,
        comment: "Thanks a lot for your feedback!"
      )
    end
end
