class IntercomNewApplicantCreateJob < ApplicationJob
  queue_as :default
  attr_reader :applicant

  def perform(applicant)
    return if Rails.env.test?

    @applicant = applicant
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: applicant.email, name: applicant.name)

    intercom.update_user(user, phone: applicant.phone, college: applicant_college_name, application_round: open_round_name, university: applicant_university)
    IntercomLastApplicantEventUpdateJob.perform_later(applicant, 'submitted_application')
  end

  def open_round_name
    ApplicationRound.open_round.display_name
  end

  def applicant_college_name
    applicant.college&.name || applicant.college_text
  end

  def applicant_university
    applicant.college&.replacement_university&.name
  end
end
