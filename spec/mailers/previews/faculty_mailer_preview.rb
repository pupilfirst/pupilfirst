class FacultyMailerPreview < ActionMailer::Preview
  def connect_request_confirmed
    connect_slot = ConnectSlot.new(
      faculty: Faculty.first,
      slot_at: 4.days.from_now
    )

    connect_request = ConnectRequest.new(
      connect_slot: connect_slot,
      startup: Startup.first,
      questions: "Question 1) This is question 1.\nQuestion 2) This is question 2.\n",
      status: ConnectRequest::STATUS_CONFIRMED,
      meeting_link: 'https://google-hangouts.com/some_link'
    )

    FacultyMailer.connect_request_confirmed(connect_request)
  end

  def request_next_week_slots
    FacultyMailer.request_next_week_slots(Faculty.first)
  end

  def connect_request_feedback
    FacultyMailer.connect_request_feedback(ConnectRequest.first)
  end
end
