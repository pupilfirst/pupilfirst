module Founders
  # The service creates a founder, a user, a blank startup for the founder and an intercom user, on new founder registration.
  class RegistrationService
    def initialize(founder_params)
      @founder_params = founder_params
    end

    def register
      Founder.transaction do
        founder = create_founder
        create_blank_startup(founder)
        create_intercom_applicant(founder)
        send_login_email(founder)
        founder
      end
    end

    private

    def create_founder
      founder = Founder.where(email: @founder_params[:email]).first_or_create!(user: user)

      founder.update!(
        name: @founder_params[:name],
        email: @founder_params[:email],
        phone: @founder_params[:phone],
        reference: @founder_params[:reference],
        college_id: @founder_params[:college_id],
        college_text: @founder_params[:college_text]
      )

      founder
    end

    def create_blank_startup(founder)
      name = Startups::ProductNameGeneratorService.new.fun_name
      startup = Startup.create!(product_name: name, level: Level.zero, maximum_level: Level.zero)

      Admissions::UpdateStageService.new(startup, Startup::ADMISSION_STAGE_SIGNED_UP).execute

      # Update startup info of founder
      founder.update!(startup: startup)
      startup.update!(team_lead: founder)
    end

    def user
      @user ||= begin
        u = User.with_email(@founder_params[:email]) || User.create!(email: @founder_params[:email])
        u.regenerate_login_token if u.login_token.blank?
        u
      end
    end

    # Send login email when all's done.
    def send_login_email(founder)
      UserSessionMailer.send_login_token(founder.user, nil, true).deliver_later
    end

    # Create or update user info on Intercom.
    def create_intercom_applicant(founder)
      IntercomNewApplicantCreateJob.perform_later(founder)
    end
  end
end
