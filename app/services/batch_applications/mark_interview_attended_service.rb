module BatchApplications
  # Creates an application submission for supplied batch application for the interview stage.
  class MarkInterviewAttendedService
    def initialize(batch_application)
      @batch_application = batch_application
    end

    def execute
      return unless @batch_application.interviewable?
      interview_stage = ApplicationStage.interview_stage
      @batch_application.application_submissions.create!(application_stage: interview_stage)
    end
  end
end
