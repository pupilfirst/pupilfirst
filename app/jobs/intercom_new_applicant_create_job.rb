class IntercomNewApplicantCreateJob < ApplicationJob
  queue_as :low_priority

  class << self
    attr_writer :mock

    def mock?
      defined?(@mock) ? @mock : Rails.env.test?
    end
  end

  def perform(founder)
    return true
    # rubocop:disable Lint/UnreachableCode
    return if self.class.mock?

    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: founder.email, name: founder.name)

    intercom.update_user(
      user,
      phone: founder.phone,
      college: founder_college_name(founder),
      university: founder_university(founder),
      supplied_reference: founder.reference
    )

    # IntercomLastApplicantEventUpdateJob.perform_later(founder, 'submitted_application')
    Intercom::LevelZeroStageUpdateJob.perform_later(founder, Startup::ADMISSION_STAGE_SIGNED_UP)
    # rubocop:enable Lint/UnreachableCode
  end

  def founder_college_name(founder)
    founder.college&.name || founder.college_text
  end

  def founder_university(founder)
    founder.college&.university&.name
  end
end
