module BatchApplications
  # Used to determine the status of a stage in the progress bar.
  class StageStatusService
    def initialize(batch_application)
      @batch_application = batch_application
    end

    # Returns one of :pending, :ongoing, :complete, :expired, :rejected, or :not_applicable
    def status(stage_number)
      application_stage_number = @batch_application.application_stage.number
      application_status = @batch_application.status

      if stage_number == application_stage_number
        application_status == :promoted ? :pending : application_status
      elsif stage_number < application_stage_number
        :complete
      else
        application_status.in?([:ongoing, :submitted, :promoted]) ? :pending : :not_applicable
      end
    end
  end
end
