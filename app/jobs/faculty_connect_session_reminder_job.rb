class FacultyConnectSessionReminderJob < ActiveJob::Base
  queue_as :default

  def perform(connect_request_id)
    @connect_request_id = connect_request_id

    return unless job_is_relevant?

    @startup_name = connect_request.startup.product_name
    @startup_url = Rails.application.routes.url_helpers.startup_url(connect_request.startup)
    @faculty_name = connect_request.faculty.name
    @faculty_url = Rails.application.routes.url_helpers.faculty_url(connect_request.faculty)
    @meeting_link = connect_request.meeting_link
    @questions = connect_request.questions

    remind_founders_on_slack
    remind_faculty_on_slack
    remind_ops_team_on_slack
  end

  def remind_founders_on_slack
    PublicSlackTalk.post_message message: reminder_for_founder, founders: connect_request.startup.founders
  end

  def remind_faculty_on_slack
    PublicSlackTalk.post_message message: reminder_for_faculty, founder: connect_request.faculty
  end

  def remind_ops_team_on_slack
    PublicSlackTalk.post_message message: reminder_for_ops_team, founders: Faculty.ops_team
  end

  private

  def connect_request
    @connect_request ||= ConnectRequest.find_by id: @connect_request_id
  end

  # Ensure the job is still relevant and not rescheduled
  def job_is_relevant?
    connect_request.present? && connect_request.startup.present? && connect_request.faculty.present? &&
      connect_request.confirmed? && connect_request.slot_at.future? && connect_request.slot_at <= 30.minutes.from_now
  end

  def reminder_for_founder
    I18n.t('slack_notifications.connect_sessions.founder_reminder',
      startup_name: @startup_name, faculty_url: @faculty_url, faculty_name: @faculty_name, meeting_link: @meeting_link)
  end

  def reminder_for_faculty
    I18n.t('slack_notifications.connect_sessions.faculty_reminder',
      startup_url: @startup_url, startup_name: @startup_name, meeting_link: @meeting_link, questions: @questions)
  end

  def reminder_for_ops_team
    I18n.t('slack_notifications.connect_sessions.ops_team_reminder',
      startup_url: @startup_url, startup_name: @startup_name, faculty_url: @faculty_url, faculty_name: @faculty_name)
  end
end
