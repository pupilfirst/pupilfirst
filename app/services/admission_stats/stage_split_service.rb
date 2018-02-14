module AdmissionStats
  class StageSplitService
    def startups_split
      stages = [Startup::ADMISSION_STAGE_SIGNED_UP, Startup::ADMISSION_STAGE_SELF_EVALUATION_COMPLETED,
                Startup::ADMISSION_STAGE_R1_TASK_PASSED, Startup::ADMISSION_STAGE_R2_TASK_PASSED,
                Startup::ADMISSION_STAGE_INTERVIEW_PASSED, Startup::ADMISSION_STAGE_FEE_PAID,
                Startup::ADMISSION_STAGE_ADMITTED]

      stages.each_with_object({}) do |stage, hash|
        hash[stage] = if stage == Startup::ADMISSION_STAGE_ADMITTED
          Startup.where(admission_stage: stage).where('created_at > ?', date_time_for_admissions).count
        else
          Startup.where(admission_stage: stage).count
        end
      end
    end

    private

    def fee_payment_target
      @fee_payment_target ||= Target.find_by(key: Target::KEY_FEE_PAYMENT)
    end

    def date_time_for_admissions
      DateTime.new(2018, 1, 9)
    end
  end
end
