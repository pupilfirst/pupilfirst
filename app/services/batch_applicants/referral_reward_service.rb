module BatchApplicants
  class ReferralRewardService
    def initialize(batch_applicant)
      @batch_applicant = batch_applicant
      @referrer = @batch_applicant.referrer
    end

    def execute
      BatchApplicantMailer.referral_reward(@referrer, @batch_applicant).deliver_later
    end
  end
end
