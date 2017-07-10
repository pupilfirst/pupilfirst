module AdmissionStats
  class StageSplitService
    def self.startups_split
      stages = [Startup::ADMISSION_STAGE_SIGNED_UP, Startup::ADMISSION_STAGE_SCREENING_COMPLETED, Startup::ADMISSION_STAGE_PAYMENT_INITIATED, Startup::ADMISSION_STAGE_FEE_PAID, Startup::ADMISSION_STAGE_CODING_AND_VIDEO_PASSED, Startup::ADMISSION_STAGE_INTERVIEW_PASSED, Startup::ADMISSION_STAGE_PRESELECTION_DONE]
      stages.each_with_object({}) do |stage, hash|
        hash[stage] = Startup.where(admission_stage: stage).count
      end
    end
  end
end
