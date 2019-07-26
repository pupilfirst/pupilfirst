class FacultyConnectSessionReminderJob < ApplicationJob
  queue_as :default

  def perform(connect_request_id)
    @connect_request_id = connect_request_id

    return unless job_is_relevant?

    remind_founders_on_slack
    remind_faculty_on_slack
    remind_ops_team_on_slack if Rails.env.production?
  end

  def remind_founders_on_slack
    public_slack_message_service.post message: reminder_for_founder, founders: connect_request.startup.founders
  end

  def remind_faculty_on_slack
    public_slack_message_service.post message: reminder_for_faculty, founder: connect_request.faculty
  end

  def remind_ops_team_on_slack
    public_slack_message_service.post message: reminder_for_ops_team, founders: Faculty.ops_team
  end

  private

  def public_slack_message_service
    @public_slack_message_service ||= PublicSlack::MessageService.new
  end

  def connect_request
    @connect_request ||= ConnectRequest.find_by id: @connect_request_id
  end

  def startup_name
    @startup_name ||= connect_request.startup.name
  end

  def founder
    @founder ||= connect_request.startup.founders.first
  end

  def founder_name
    @founder_name ||= founder.name
  end

  def url_options
    @url_options ||= { host: founder.school.domains.primary.fqdn }
  end

  def founder_url
    @founder_url ||= Rails.application.routes.url_helpers.student_url(founder.id, **url_options)
  end

  def faculty_name
    @faculty_name ||= connect_request.faculty.name
  end

  def coach_url
    @coach_url ||= Rails.application.routes.url_helpers.coach_url(connect_request.faculty, **url_options)
  end

  def founder_join_session_link
    @founder_join_session_link ||= Rails.application.routes.url_helpers.connect_request_join_session_url(connect_request, **url_options)
  end

  def faculty_join_session_link
    @faculty_join_session_link ||= Rails.application.routes.url_helpers.connect_request_join_session_url(connect_request, token: connect_request.faculty.token, **url_options)
  end

  def questions
    @questions ||= connect_request.questions
  end

  # Ensure the job is still relevant and not rescheduled
  def job_is_relevant?
    connect_request.present? && connect_request.startup.present? && connect_request.faculty.present? &&
      connect_request.confirmed? && connect_request.slot_at.future? && connect_request.slot_at <= 30.minutes.from_now
  end

  def reminder_for_founder
    I18n.t('jobs.faculty_connect_session_reminder.founder_reminder',
      startup_name: startup_name, coach_url: coach_url, faculty_name: faculty_name, meeting_link: founder_join_session_link)
  end

  def reminder_for_faculty
    I18n.t('jobs.faculty_connect_session_reminder.faculty_reminder',
      founder_url: founder_url, founder_name: founder_name, meeting_link: faculty_join_session_link, questions: questions)
  end

  def reminder_for_ops_team
    I18n.t('jobs.faculty_connect_session_reminder.ops_team_reminder',
      founder_url: founder_url, founder_name: founder_name, coach_url: coach_url, faculty_name: faculty_name)
  end
end
