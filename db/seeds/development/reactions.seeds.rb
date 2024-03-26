after "development:timeline_events", "development:submission_comments" do
  puts "Seeding reactions"

  school = School.find_by(name: "Test School")
  user = school.users.find_by(email: "student1@example.com")
  student = user.students.first
  user_2 = school.users.where.not(id: user.id).first
  user_3 = school.users.where.not(id: user.id).second

  TimelineEventOwner
    .where(student: student)
    .each do |event_owner|
      event_owner.timeline_event.reactions.create!(
        user: user_2,
        reaction_value: "❤️"
      )
      event_owner.timeline_event.reactions.create!(
        user: user_3,
        reaction_value: "🌸"
      )
    end
end
