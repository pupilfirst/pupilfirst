class FacultyMailerPreview < ActionMailer::Preview
  def connect_request_confirmed
    FacultyMailer.connect_request_confirmed(connect_request)
  end

  def request_next_week_slots
    FacultyMailer.request_next_week_slots(Faculty.first)
  end

  def connect_request_feedback
    FacultyMailer.connect_request_feedback(connect_request)
  end

  def student_submission_notification
    founder = Founder.first

    timeline_event = TimelineEvent.new(
      id: 1,
      founders: founder.startup.founders,
      target: founder.course.targets.first
    )

    faculty = founder.school.faculty.first

    FacultyMailer.student_submission_notification(timeline_event, faculty)
  end

  private

  def connect_request
    ConnectRequest.new(
      id: 1,
      connect_slot: connect_slot,
      startup: Startup.last,
      questions: Faker::Lorem.paragraphs(number: 2).join("\n\n"),
      status: ConnectRequest::STATUS_CONFIRMED,
      meeting_link: 'https://example.com/meeting_url'
    )
  end

  def connect_slot
    ConnectSlot.new(
      faculty: Faculty.first,
      slot_at: 2.days.from_now
    )
  end
end
