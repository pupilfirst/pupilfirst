require 'rails_helper'

describe Coupons::ApplicabilityService do
  subject { described_class.new(coupon, founder) }
  let!(:coupon) { create :coupon }
  let!(:founder) { create :founder }

  describe '#applicable?' do
    context 'when the coupon is of type DISCOUNT' do
      it 'returns true' do
        expect(subject.applicable?).to eq(true)
      end
    end

    context 'when the coupon is of type MSP' do
      it 'returns true only if the founder has an MSP email' do
        coupon.update!(coupon_type: Coupon::TYPE_MSP)

        founder.update!(email: 'something@something.com')
        expect(subject.applicable?).to eq(false)

        founder.update!(email: 'something@studentpartner.com')
        expect(subject.applicable?).to eq(true)
      end
    end

    context 'when the coupon is of type MOOC_MERIT' do
      let!(:college) { create :college }
      let!(:mooc_student) { create :mooc_student, user: founder.user, college: college }

      it 'returns true only if the founder has a MOOC score > 30' do
        coupon.update!(coupon_type: Coupon::TYPE_MOOC_MERIT)

        expect(mooc_student).to receive(:score).and_return(rand(30))
        expect(subject.applicable?).to eq(false)

        expect(mooc_student).to receive(:score).and_return(31 + rand)
        expect(subject.applicable?).to eq(true)
      end
    end
  end

  describe '#error_message' do
    context 'when the coupon is of type DISCOUNT' do
      it 'returns nil' do
        expect(subject.error_message).to be_nil
      end
    end

    context 'when the coupon is of type MSP' do
      it 'returns the appropriate error if founder does not have an MSP email' do
        coupon.update!(coupon_type: Coupon::TYPE_MSP)

        founder.update!(email: 'something@something.com')
        expect(subject.error_message).to eq('this code is only valid for Microsoft Student Partners')

        founder.update!(email: 'something@studentpartner.com')
        expect(subject.error_message).to be_nil
      end
    end

    context 'when the coupon is of type MOOC_MERIT' do
      let!(:college) { create :college }
      let!(:mooc_student) { create :mooc_student, user: founder.user, college: college }

      it 'returns the appropriate error if founder does not have a MOOC score > 30' do
        coupon.update!(coupon_type: Coupon::TYPE_MOOC_MERIT)

        expect(mooc_student).to receive(:score).and_return(rand(30))
        expect(subject.error_message).to eq('this code is only valid for students who scored above 30% in our MOOC')

        expect(mooc_student).to receive(:score).and_return(31 + rand)
        expect(subject.error_message).to be_nil
      end
    end
  end
end
