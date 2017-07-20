require 'rails_helper'

feature 'Admission Fee Payment' do
  include_context 'mocked_instamojo'
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.admin }
  let(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:tet_team_update) { create :timeline_event_type, :team_update }
  let(:referrer_founder) { create :founder }
  let(:coupon) { create :coupon, referrer: referrer_founder }
  let(:sample_payment) { create :payment, amount: 500 }

  before do
    sign_in_user founder.user
  end

  # ensure authorization is in place
  context 'Founder visits fee payment page' do
    scenario 'He has not completed the cofounder addition prerequisite' do
      visit admissions_fee_path

      # raises 404 as founder is not yet authorized
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end

    scenario 'He has completed the cofounder addition prerequisite' do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
      visit admissions_fee_path

      # successfully shows the founder the payment page
      expect(page).to have_content('You now need to pay the membership fee.')
    end
  end

  # ensure payment flow works with and without coupons
  context 'Authorized founder attempts to pay the registration fees' do
    before do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
    end

    scenario 'He completes payment without applying any coupon' do
      visit admissions_fee_path

      # he will be asked to pay the full amount
      expect(page).to have_content('Team membership fee is ₹1000')
      click_on 'Pay Now'

      # he must be re-directed to the payment's long_url.
      expect(page).to have_content("redirected to: #{long_url}")

      payment = Payment.last
      # his startup should now have a payment with the right amount
      expect(payment.startup).to eq(startup)
      expect(payment.amount).to eq(1000.0)

      # mimic a successful payment
      payment.update!(
        instamojo_payment_request_status: 'Completed',
        instamojo_payment_status: 'Credit',
        paid_at: Time.now
      )
      Admissions::PostPaymentService.new(payment: payment).execute

      # payment target should now be marked complete
      fee_payment_status = Targets::StatusService.new(fee_payment_target, founder).status
      expect(fee_payment_status).to eq(Targets::StatusService::STATUS_COMPLETE)

      # he should now also have a referral coupon
      expect(founder.referral_coupon).to_not eq(nil)
    end

    scenario 'He completes payment applying a referral coupon' do
      visit admissions_fee_path

      # page should have coupon form
      expect(page).to have_content('Have a discount coupon?')

      # he applies the coupon
      fill_in 'admissions_coupon_code', with: coupon.code
      click_button 'Apply Code'
      expect(page).to have_content("Coupon with code #{coupon.code}applied!")

      # he removes the applied coupon
      click_button 'Remove'
      expect(page).to have_content('Have a discount coupon?')
      expect(page).to have_content('Team membership fee is ₹1000')

      # he applies it back :)
      fill_in 'admissions_coupon_code', with: coupon.code
      click_button 'Apply Code'

      # He should be shown the discounted amount. The original amount is crossed out (not detected by this test).
      expect(page).to have_content('Team membership fee is ₹1000 ₹750.')

      click_on 'Pay Now'

      # payment created should be for the discounted amount
      payment = Payment.last
      expect(payment.amount).to eq(750.0)

      # the ReferralRewardService will be called later
      expect_any_instance_of(Founders::ReferralRewardService).to receive(:execute)

      # mimic a successful payment
      payment.update!(
        instamojo_payment_request_status: 'Completed',
        instamojo_payment_status: 'Credit',
        paid_at: Time.now
      )
      Admissions::PostPaymentService.new(payment: payment).execute

      # the coupon must be now marked redeemed for the startup
      coupon_usage = CouponUsage.where(coupon: coupon, startup: startup).last
      expect(coupon_usage.redeemed_at).to_not eq(nil)
    end

    context 'when there are confirmed and unconfirmed founders' do
      let!(:confirmed_founder) { create :founder, startup: startup }
      let!(:unconfirmed_founder) { create :founder, invited_startup: startup }

      scenario 'logged in founder needs to pay for both confirmed and unconfirmed founders' do
        visit admissions_fee_path

        expect(page).to have_content('Team membership fee is ₹3000')
      end
    end
  end

  # test an edge case of archiving pending payment requests
  context 'Founder has an incomplete payment request' do
    before do
      # assign the startup an existing payment
      sample_payment.update!(startup: startup)

      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
      visit admissions_fee_path
    end

    scenario 'Founder resubmits the payment form' do
      # he issues a new payment request
      expect(page).to have_content('Team membership fee is ₹1000')
      click_on 'Pay Now'
      expect(page).to have_content("redirected to: #{long_url}")

      # the existing payment must be archived and a new one created
      payment = Payment.last
      expect(startup.reload.payments.last).to eq(payment)
      expect(startup.archived_payments).to include(sample_payment)
    end
  end
end
