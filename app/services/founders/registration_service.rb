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
      @founder = Founder.create!(
        name: @founder_params[:name],
        email: @founder_params[:email],
        phone: @founder_params[:phone],
        reference: @founder_params[:reference],
        college_id: @founder_params[:college_id],
        college_text: @founder_params[:college_text],
        startup_admin: true
      )
    end

    def create_blank_startup
      name_generator = Startups::ProductNameGeneratorService.new
      name = name_generator.fun_name

      while Startup.find_by(product_name: name).present?
        name = name_generator.fun_name
      end

      startup = Startup.create!(product_name: name, level: Level.zero)

      # Update startup info of founder
      @founder.update!(startup: startup)
    end

    def create_or_update_user
      user = User.with_email(@founder.email).first || User.create!(email: @founder.email)
      # Send login email when all's done.
      UserSessionMailer.send_login_token(@founder.user, nil, true).deliver_later

      # Update user info of founder
      @founder.update!(user: user)
    end

    def create_intercom_applicant
      # Create or update user info on intercom
      IntercomNewApplicantCreateJob.perform_later @founder if @founder.present?
    end
  end
end
