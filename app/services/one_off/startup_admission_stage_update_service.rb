module OneOff
  class StartupAdmissionStageUpdateService
    def execute
      Startup.where(level: level_0).each do |startup|
        Admissions::UpdateStageService.new(startup, stage(startup)).execute
      end
    end

    private

    def stage(startup)
      team_lead = startup.admin

      if complete?(fee_payment_target, team_lead)
        'Fee Paid'
      elsif startup.payment.present?
        'Payment Initiated'
      elsif complete?(cofounder_addition_target, team_lead)
        'Added Cofounders'
      elsif complete?(screening_target, team_lead)
        'Screening Completed'
      else
        'Signed Up'
      end
    end

    def screening_target
      @screening_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_SCREENING)
    end

    def fee_payment_target
      @fee_payment_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
    end

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
    end

    def attend_interview_target
      @attend_interview_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_ATTEND_INTERVIEW)
    end

    def complete?(target, team_lead)
      target.status(team_lead).in? [Targets::StatusService::STATUS_COMPLETE, Targets::StatusService::STATUS_NEEDS_IMPROVEMENT]
    end

    def pending?(target, team_lead)
      target.status(team_lead) == [Targets::StatusService::STATUS_PENDING]
    end

    def level_0
      @level_0 ||= Level.find_by(number: 0)
    end
  end
end
