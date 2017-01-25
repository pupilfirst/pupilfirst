module BatchApplicants
  class ReferralRefundService
    def initialize(batch_applicant)
      @batch_applicant = batch_applicant
      @referrer = @batch_applicant.referrer
    end

    def execute
      BatchApplicantMailer.referral_refund(@referrer, @batch_applicant).deliver_later
    end
  end
end
