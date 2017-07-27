module AdmissionStats
  class StageSplitService
    def startups_split
      stages = [Startup::ADMISSION_STAGE_SIGNED_UP, Startup::ADMISSION_STAGE_SCREENING_COMPLETED, Startup::ADMISSION_STAGE_COFOUNDERS_ADDED, Startup::ADMISSION_STAGE_PAYMENT_INITIATED, Startup::ADMISSION_STAGE_FEE_PAID]
      stages.each_with_object({}) do |stage, hash|
        hash[stage] = Startup.where(admission_stage: stage).count
      end
    end
  end
end
