require 'rails_helper'

describe Startups::FeePayableService do
  subject { described_class.new(startup) }

  let(:startup) { create :startup }

  before do
    # Add an invited and an exited founder to the startup.
    create :founder, invited_startup: startup # will be billed.
    create :founder, startup: startup, exited: true # will not be billed.
  end

  describe '#undiscounted_fee' do
    it 'returns the total base fee for all billed founders' do
      expect(subject.undiscounted_fee(period: 3)). to eq(36_000)
    end
  end

  describe '#fee_payable' do
    let(:discount_coupon) { create :coupon, discount_percentage: 25 }

    before do
      # Apply the discount coupon to the startup.
      CouponUsage.create!(startup: startup, coupon: discount_coupon)
    end

    it 'returns the fee payable after accounting for all discounts' do
      expect(subject.fee_payable(period: 3)).to eq(18_000)
    end
  end
end
