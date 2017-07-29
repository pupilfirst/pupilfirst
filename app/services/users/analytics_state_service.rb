module Users
  class AnalyticsStateService
    ADMISSION_STAGE_SIGNED_UP = -'signed_up'
    ADMISSION_STAGE_SCREENING_COMPLETE = -'screening_complete'
    ADMISSION_STAGE_PAYMENT_INITIATED = -'payment_initiated'
    ADMISSION_STAGE_PAYMENT_COMPLETED = -'payment_completed'
    ADMISSION_STAGE_PAYMENT_BYPASSED = -'payment_bypassed'
    ADMISSION_STAGE_ADMITTED = -'admitted'

    def initialize(user)
      @user = user
    end

    def state
      hash = { email: @user.email }
      hash[:name] = name if name.present?

      if startup.present?
        hash[:startup] = {
          id: startup.id,
          admissions_stage: admissions_stage,
          product_name: startup.product_name
        }
      end

      hash
    end

    private

    def name
      @user.founder&.name || @user.mooc_student&.name
    end

    def startup
      @startup ||= @user.founder&.startup
    end

    def admissions_stage # rubocop:disable Metrics/PerceivedComplexity
      if startup.level.number.positive?
        ADMISSION_STAGE_ADMITTED
      elsif fee_payment_complete?
        if payment_present?
          ADMISSION_STAGE_PAYMENT_COMPLETED
        else
          ADMISSION_STAGE_PAYMENT_BYPASSED
        end
      elsif payment_present?
        ADMISSION_STAGE_PAYMENT_INITIATED
      elsif screening_complete?
        ADMISSION_STAGE_SCREENING_COMPLETE
      else
        ADMISSION_STAGE_SIGNED_UP
      end
    end

    def fee_payment_complete?
      Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT).status(@user.founder) == Targets::StatusService::STATUS_COMPLETE
    end

    def payment_present?
      startup.payments.any?
    end

    def screening_complete?
      Target.find_by(key: Target::KEY_ADMISSIONS_SCREENING).status(@user.founder) == Targets::StatusService::STATUS_COMPLETE
    end
  end
end
