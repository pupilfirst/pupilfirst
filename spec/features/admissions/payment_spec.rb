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
  let(:referrer_startup) { create :startup }
  let(:referrer_payment) { create :payment, :paid, startup: referrer_startup }
  let(:coupon) { create :coupon, referrer_startup: referrer_startup }

  before do
    sign_in_user founder.user
  end

  # Ensure authorization is in place.
  context 'Founder visits fee payment page' do
    scenario 'He has not completed the cofounder addition prerequisite' do
      visit admissions_fee_path

      # Raises 404 as founder is not yet authorized.
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end

    scenario 'He has completed the cofounder addition prerequisite' do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
      visit admissions_fee_path

      # Successfully shows the founder the payment page.
      expect(page).to have_content('You now need to pay the membership fee.')
    end
  end

  # Ensure payment flow works with and without coupons.
  context 'Authorized founder attempts to pay the registration fees' do
    before do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
    end

    scenario 'He completes payment without applying any coupon' do
      visit admissions_fee_path

      # He will be asked to pay the full amount.
      expect(page).to have_content('Team membership fee is ₹1000')
      click_on 'Pay Now'

      # He must be re-directed to the payment's long_url.
      expect(page).to have_content("redirected to: #{long_url}")

      payment = Payment.last
      # His startup should now have a payment with the right amount.
      expect(payment.startup).to eq(startup)
      expect(payment.amount).to eq(1000.0)

      # Mimic a successful payment.
      payment.update!(
        instamojo_payment_request_status: 'Completed',
        instamojo_payment_status: 'Credit',
        paid_at: Time.now
      )
      Admissions::PostPaymentService.new(payment: payment).execute

      # Payment target should now be marked complete.
      fee_payment_status = Targets::StatusService.new(fee_payment_target, founder).status
      expect(fee_payment_status).to eq(Targets::StatusService::STATUS_COMPLETE)

      # He should now also have a referral coupon.
      expect(startup.referral_coupon).to_not eq(nil)
    end

    scenario 'He completes payment applying a referral coupon' do
      visit admissions_fee_path

      # Page should have coupon form.
      expect(page).to have_content('Have a referral coupon?')

      # He applies the coupon.
      fill_in 'admissions_coupon_code', with: coupon.code
      click_button 'Apply Code'
      expect(page).to have_content("Coupon with code #{coupon.code}applied!")
      expect(startup.reload.coupon_usage).to_not eq(nil)

      # He removes the applied coupon.
      click_button 'Remove'
      expect(page).to have_content('Have a referral coupon?')
      expect(startup.reload.coupon_usage).to eq(nil)

      # He applies it back :)
      fill_in 'admissions_coupon_code', with: coupon.code
      click_button 'Apply Code'

      # He should be shown the discounted amount. The original amount is crossed out (not detected by this test).
      expect(page).to have_content('You will unlock 15 extra days of SV.CO subscription on fee payment!')

      click_on 'Pay Now'

      # Mimic a successful payment.
      payment = Payment.last
      payment.update!(
        instamojo_payment_request_status: 'Completed',
        instamojo_payment_status: 'Credit',
        paid_at: Time.now
      )

      # Store the current billing_end_at for user and referrer.
      user_end_date = payment.billing_end_at
      referrer_end_date = referrer_payment.billing_end_at

      Admissions::PostPaymentService.new(payment: payment).execute

      # The coupon usage must be now marked redeemed for the startup.
      expect(startup.reload.coupon_usage.redeemed_at).to_not eq(nil)

      # the user and referrer should have received 15 and 10 days subscription extension respectively
      new_user_end_date = payment.billing_end_at.beginning_of_minute
      new_referrer_end_date = referrer_payment.reload.billing_end_at.beginning_of_minute
      expect(new_user_end_date).to eq((user_end_date + 15.days).beginning_of_minute)
      expect(new_referrer_end_date).to eq((referrer_end_date + 10.days).beginning_of_minute)

      # The referrer should have received an email informing of his/her reward.
      open_email(referrer_startup.admin.email)
      expect(current_email.subject).to include('Your startup has unlocked SV.CO referral rewards!')
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

  # Test an edge case of archiving pending payment requests.
  context 'Founder has an incomplete payment request' do
    let!(:previous_payment) { create :payment, :requested, startup: startup, amount: 2000 }

    before do
      complete_target founder, screening_target
      startup.founders << create(:founder)
      startup.founders << create(:founder)
      complete_target founder, cofounder_addition_target
    end

    scenario 'Founder resubmits the payment form' do
      visit admissions_fee_path
      expect(page).to have_content('Team membership fee is ₹3000')

      # He issues a new payment request.
      click_on 'Pay Now'

      expect(page).to have_content("redirected to: #{long_url}")

      # The previous payment must be archived and a new one created.
      new_payment = startup.reload.payments.last
      expect(new_payment).not_to eq(previous_payment)
      expect(startup.archived_payments).to include(previous_payment)
    end
  end
end
