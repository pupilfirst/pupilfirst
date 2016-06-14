class FacultyMailerPreview < ActionMailer::Preview
  def connect_request_confirmed
    connect_request = ConnectRequest.last

    FacultyMailer.connect_request_confirmed(connect_request)
  end

  def request_next_week_slots
    FacultyMailer.request_next_week_slots(Faculty.first)
  end

  def connect_request_feedback
    FacultyMailer.connect_request_feedback(ConnectRequest.first)
  end
end
