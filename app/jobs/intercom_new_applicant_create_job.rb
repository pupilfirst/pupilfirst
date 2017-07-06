class IntercomNewApplicantCreateJob < ApplicationJob
  queue_as :default

  class << self
    attr_writer :mock

    def mock?
      defined?(@mock) ? @mock : Rails.env.test?
    end
  end

  def perform(founder)
    return if self.class.mock?

    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: founder.email, name: founder.name)

    intercom.update_user(
      user,
      phone: founder.phone,
      college: founder_college_name(founder),
      university: founder_university(founder)
    )

    # IntercomLastApplicantEventUpdateJob.perform_later(founder, 'submitted_application')
    Intercom::LevelZeroStageUpdateJob.perform_later(founder, 'Signed Up')
  end

  def founder_college_name(founder)
    founder.college&.name || founder.college_text
  end

  def founder_university(founder)
    founder.college&.university&.name
  end
end
