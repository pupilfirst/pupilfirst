module Founders
  # The service creates a founder, a user, a blank startup for the founder and an intercom user, on new founder registration.
  class RegistrationService
    def initialize(founder_params)
      @founder_params = founder_params
    end

    def register
      Founder.transaction do
        startup = create_blank_startup
        founder = create_founder(startup)
        create_intercom_applicant(founder)
        send_login_email(founder)
        founder
      end
    end

    private

    def create_founder(startup)
      founder = Founder.where(user: user).first_or_create!(
        name: @founder_params[:name],
        phone: @founder_params[:phone],
        reference: @founder_params[:reference],
        college_id: @founder_params[:college_id],
        college_text: @founder_params[:college_text],
        coder: @founder_params[:coder],
        startup: startup
      )

      startup.update!(team_lead: founder)

      founder
    end

    def create_blank_startup
      name = Startups::ProductNameGeneratorService.new.fun_name
      startup = Startup.create!(product_name: name, level: Level.zero)

      Admissions::UpdateStageService.new(startup, Startup::ADMISSION_STAGE_SIGNED_UP).execute

      startup
    end

    def user
      @user ||= begin
        User.with_email(@founder_params[:email]) || User.create!(email: @founder_params[:email])
      end
    end

    # Send login email when all's done.
    def send_login_email(founder)
      school = founder.startup.course.school
      domain = school.domains.first
      user = founder.user
      referer = nil
      shared_device = true

      Users::MailLoginTokenService.new(school, domain, user, referer, shared_device).execute
    end

    # Create or update user info on Intercom.
    def create_intercom_applicant(founder)
      IntercomNewApplicantCreateJob.perform_later(founder)
    end
  end
end
