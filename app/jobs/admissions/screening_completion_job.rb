module Admissions
  class ScreeningCompletionJob < ApplicationJob
    queue_as :default

    def perform(founder, screening_response)
      return if founder.screening_data.present?

      # Mark the screening target as complete
      Admissions::CompleteTargetService.new(founder, Target::KEY_SCREENING).execute

      # Store screening response of the founder
      formatted_response = Typeform::AnswersExtractionService.new(screening_response).execute
      founder.update!(screening_data: formatted_response)

      # Mark as screening completed on Intercom
      Intercom::LevelZeroStageUpdateJob.perform_now(founder, Startup::ADMISSION_STAGE_SELF_EVALUATION_COMPLETED)
    end
  end
end
