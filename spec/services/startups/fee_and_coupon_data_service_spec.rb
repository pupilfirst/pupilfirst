require 'rails_helper'

describe Startups::FeeAndCouponDataService do
  subject { described_class.new(startup) }

  let(:startup) { create :level_0_startup }
  let(:expected_total_fee) { Startups::FeeAndCouponDataService::BASE_FEE * startup.billing_founders_count }
  let(:expected_emi) { (expected_total_fee / 6).to_i }

  describe '#emi' do
    context 'when calculated emi is less than or equal to remaining payable amount' do
      it 'returns the calculated emi' do
        expect(subject.emi).to eq(expected_emi)
      end
    end

    context 'when emi has been paid for five months' do
      let(:startup) { create :startup }
      let(:already_paid) { (expected_emi * 5).to_i }

      before do
        create :payment, :paid, startup: startup, amount: already_paid
      end

      it 'returns remaining payable amount' do
        remaining_payable = expected_total_fee - already_paid
        expect(subject.emi).to eq(remaining_payable)
      end
    end
  end

  describe '#props' do
    context 'when a startup has no coupon' do
      it 'returns default props with coupon as nil' do
        expect(subject.props).to eq(
          fee: {
            originalFee: expected_total_fee,
            discountedFee: expected_total_fee,
            payableFee: expected_total_fee,
            emi: expected_emi
          },
          coupon: nil
        )
      end
    end

    context 'when startup has a coupon and is on its last payment' do
      let(:startup) { create :startup }
      let(:coupon_instructions) { Faker::Lorem.sentence }
      let(:coupon) { create :coupon, instructions: coupon_instructions }
      let(:expected_discounted_fee) { (Startups::FeeAndCouponDataService::BASE_FEE * startup.billing_founders_count * coupon.discount_percentage / 100).to_i }
      let(:calculated_emi) { (expected_discounted_fee / 6).to_i }
      let(:already_paid) { (calculated_emi * 5).to_i }

      before do
        coupon.coupon_usages.create!(startup: startup)
        create :payment, :paid, startup: startup, amount: already_paid
      end

      it 'returns default props with coupon details' do
        remaining_payable = expected_discounted_fee - already_paid

        expect(subject.props).to eq(
          fee: {
            originalFee: expected_total_fee,
            discountedFee: expected_discounted_fee,
            payableFee: remaining_payable,
            emi: remaining_payable
          },
          coupon: {
            code: coupon.code,
            discount: coupon.discount_percentage,
            instructions: coupon_instructions
          }
        )
      end
    end
  end
end
