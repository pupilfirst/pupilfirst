module OneOff
  class StartupAdmissionStageUpdateService
    def execute
      Startup.where(level: level_0).each do |startup|
        startup.update!(admission_stage: stage(startup))
      end
    end

    private

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def stage(startup)
      team_lead = startup.admin

      if complete?(pre_selection_target, team_lead)
        'Pre-Selection Done'
      elsif complete?(attend_interview_target, team_lead)
        'Interview Passed'
      elsif pending?(attend_interview_target, team_lead)
        'Coding & Video Passed'
      elsif complete?(fee_payment_target, team_lead)
        'Fee Paid'
      elsif startup.payment.present?
        'Payment Initiated'
      elsif complete?(screening_target, team_lead)
        'Screening Completed'
      else
        'Signed Up'
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def screening_target
      @screening_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_SCREENING)
    end

    def fee_payment_target
      @fee_payment_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
    end

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
    end

    def coding_task_target
      @coding_task_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_CODING_TASK)
    end

    def video_task_target
      @video_task_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_VIDEO_TASK)
    end

    def attend_interview_target
      @attend_interview_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_ATTEND_INTERVIEW)
    end

    def pre_selection_target
      @pre_selection_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_PRE_SELECTION)
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
