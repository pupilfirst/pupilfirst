module AdmissionStats
  class StageSplitService
    def startups_split
      stages = [Startup::ADMISSION_STAGE_SIGNED_UP, Startup::ADMISSION_STAGE_SCREENING_COMPLETED, Startup::ADMISSION_STAGE_COFOUNDERS_ADDED, Startup::ADMISSION_STAGE_PAYMENT_INITIATED, Startup::ADMISSION_STAGE_FEE_PAID, Startup::ADMISSION_STAGE_ADMITTED]
      stages.each_with_object({}) do |stage, hash|
        hash[stage] = if stage == Startup::ADMISSION_STAGE_ADMITTED
          Startup.where(admission_stage: stage).joins(:timeline_events).where(timeline_events: { target: fee_payment_target }).where('timeline_events.status_updated_at > ?', date_time_for_admissions).count
        else
          Startup.where(admission_stage: stage).count
        end
      end
    end

    private

    def fee_payment_target
      @fee_payment_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
    end

    def date_time_for_admissions
      DateTime.new(2017, 7, 10)
    end
  end
end
