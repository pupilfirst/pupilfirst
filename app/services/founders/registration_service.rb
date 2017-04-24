module Founders
  # The service creates a founder, a user, a blank startup for the founder and an intercom user, on new founder registration.
  class RegistrationService
    def initialize(founder_params)
      @founder_params = founder_params
    end

    def register
      Founder.transaction do
        founder = create_founder
        create_blank_startup
        create_or_update_user
        create_intercom_applicant
        founder
      end
    end

    private

    def create_founder
      @founder = Founder.where(email: @founder_params[:email]).first_or_create!

      @founder.update!(
        name: @founder_params[:name],
        email: @founder_params[:email],
        phone: @founder_params[:phone],
        reference: @founder_params[:reference],
        college_id: @founder_params[:college_id],
        college_text: @founder_params[:college_text],
        startup_admin: true
      )

      @founder
    end

    def create_blank_startup
      name = Startups::ProductNameGeneratorService.new.fun_name
      startup = Startup.create!(product_name: name, level: Level.zero, maximum_level: Level.zero)

      # Update startup info of founder
      @founder.update!(startup: startup)
    end

    def create_or_update_user
      user = User.with_email(@founder.email).first || User.create!(email: @founder.email)

      # Update user info of founder
      @founder.update!(user: user)

      # Send login email when all's done.
      UserSessionMailer.send_login_token(@founder.user, nil, true).deliver_later
    end

    def create_intercom_applicant
      # Create or update user info on intercom
      IntercomNewApplicantCreateJob.perform_later @founder if @founder.present?
    end
  end
end
