module Admissions
  class ScreeningCompletionJob < ApplicationJob
    queue_as :default

    def perform(founder, screening_response)
      # Mark the screening target as complete
      Admissions::CompleteTargetService.new(founder, Target::KEY_ADMISSIONS_SCREENING).execute

      # Store screening response of the founder
      formatted_response = Typeform::AnswersExtractionService.new(screening_response).execute
      founder.update!(screening_data: formatted_response) if founder.screening_data.blank?

      # Mark as screening completed on Intercom
      Intercom::LevelZeroStageUpdateJob.perform_now(founder, 'Screening Completed')
    end
  end
end
