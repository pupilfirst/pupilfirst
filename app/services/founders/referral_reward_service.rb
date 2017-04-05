module Founders
  class ReferralRewardService
    def initialize(founder)
      @founder = founder
      @referrer = @founder.startup.referrer
    end

    def execute
      FounderMailer.referral_reward(@referrer, @founder).deliver_later
    end
  end
end
