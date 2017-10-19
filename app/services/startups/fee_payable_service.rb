module Startups
  # Returns the subscription fee payable by a startup.
  #
  # The fee is calculated accounting for bulk payment and discount coupon, if any.
  class FeePayableService
    # Discount percentages for bulk payment.
    DISCOUNT_PERCENTAGE_THREE_MONTHS = 33.33
    DISCOUNT_PERCENTAGE_SIX_MONTHS = 50

    def initialize(startup)
      @startup = startup
    end

    def fee_payable(period:)
      fee = undiscounted_fee(period: period)

      # Apply bulk payment discount, if applicable.
      fee = (fee - (bulk_payment_discount(period) * fee)) unless period == 1

      # Apply discount coupon, if any.
      fee = (fee - (coupon_discount * fee)) if discount_coupon_applied?

      # Return a minimum fee of Rs.1.
      [1, fee.round(-1)].max
    end

    def undiscounted_fee(period:)
      billing_founders_count * founder_fee * period
    end

    private

    def billing_founders_count
      @billing_founders_count ||= @startup.billing_founders_count
    end

    def founder_fee
      @founder_fee ||= @startup.founder_fee || Founder::FEE
    end

    def bulk_payment_discount(period)
      case period
        when 3
          DISCOUNT_PERCENTAGE_THREE_MONTHS
        when 6
          DISCOUNT_PERCENTAGE_SIX_MONTHS
        else
          raise 'Unexpected period specified'
      end.to_f / 100
    end

    def coupon_discount
      coupon.discount_percentage.to_f / 100
    end

    def discount_coupon_applied?
      coupon&.discount_percentage&.present?
    end

    def coupon
      @coupon ||= @startup.coupon_usage&.coupon
    end
  end
end
