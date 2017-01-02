module Startups
  # When given a batch, it goes through all selected applications and creates Startup and Founder entries for them.
  class OnboardService
    def initialize(batch)
      @batch = batch
    end

    def execute
      raise "Invitations for this batch were already sent at #{@batch.invites_sent_at}" if @batch.invites_sent_at.present?

      startups = create_startups

      startups.each do |startup|
        Startups::PrepopulateTimelineService.new(startup).execute

        # TODO: Mail has been disabled. Remove completely if this is unused.
        # send_notification_emails(startup)
      end

      @batch.update!(invites_sent_at: Time.now)
    end

    private

    def create_startups
      Batch.transaction do
        @batch.selected_applications.map do |application|
          startup = create_startup(application)

          application.batch_applicants.each do |applicant|
            create_founder(applicant, startup, team_lead: application.team_lead == applicant)
          end

          startup
        end
      end
    end

    def create_startup(batch_application)
      return batch_application.startup if batch_application.startup.present?

      begin
        name = ProductNameGeneratorService.new.fun_name
        @batch.startups.create!(product_name: name, batch_application: batch_application)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end

    def create_founder(applicant, startup, team_lead:)
      return applicant.founder if applicant.founder.present?

      user = User.with_email(applicant.email).first
      user = User.create!(email: applicant.email) if user.blank?

      # Create founder for startup.
      founder = startup.founders.create!(
        user_id: user.id,
        name: applicant.name,
        email: user.email,
        startup_admin: team_lead,
        gender: applicant.gender,
        born_on: applicant.born_on,
        college_id: applicant.college_id,
        communication_address: applicant.current_address,
        roles: [applicant.role],
        phone: applicant.phone,
        identification_proof: applicant.id_proof
      )

      # Link founder to applicant.
      applicant.update!(founder: founder)
    end

    def send_notification_emails(startup)
      StartupMailer.batch_start(startup).deliver_later
    end
  end
end
