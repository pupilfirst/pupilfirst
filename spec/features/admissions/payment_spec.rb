require 'rails_helper'

feature 'Admission Fee Payment' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.team_lead }
  let(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:tet_team_update) { create :timeline_event_type, :team_update }
  let(:referrer_startup) { create :startup }
  let(:referrer_payment) { create :payment, :paid, startup: referrer_startup }
  let(:coupon) { create :coupon, referrer_startup: referrer_startup }
  let(:long_url) { Faker::Internet.url }

  # Ensure authorization is in place.
  context 'Founder visits fee payment page' do
    scenario 'He has not completed the cofounder addition prerequisite' do
      sign_in_user founder.user, referer: fee_founder_path

      # Raises 404 as founder is not yet authorized.
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end

    scenario 'He has completed the cofounder addition prerequisite' do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
      create :payment, startup: startup

      sign_in_user founder.user, referer: fee_founder_path

      # Successfully shows the founder the payment page.
      expect(page).to have_content('Please pay the membership fee to continue.')
    end
  end

  # Ensure payment flow works with and without coupons.
  context 'Authorized founder attempts to pay fees' do
    let!(:payment) { create :payment, startup: startup }

    before do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
      create :founder, startup: startup

      # Stub the request to create new payment.
      stub_request(:post, 'https://www.example.com/payment-requests/')
        .with(body: hash_including(
          amount: '2000.0',
          buyer_name: founder.name,
          email: founder.email,
          purpose: 'Fee for SV.CO'
        ))
        .to_return(body: {
          success: true,
          payment_request: {
            id: 'NEW_ID',
            status: 'Pending',
            shorturl: 'https://example.com/short',
            longurl: long_url
          }
        }.to_json)

      # Stub the request to refresh payment after redirect.
      stub_request(:get, 'https://www.example.com/payment-requests/NEW_ID/PAYMENT_ID/')
        .to_return(body: {
          success: true,
          payment_request: {
            status: Instamojo::PAYMENT_REQUEST_STATUS_COMPLETED,
            payment: {
              status: Instamojo::PAYMENT_STATUS_CREDITED,
              fees: 123.45
            }
          }
        }.to_json)
    end

    scenario 'He completes payment without applying any coupon' do
      sign_in_user founder.user, referer: fee_founder_path

      # He will be asked to pay the full amount.
      expect(page).to have_content('Please pay the membership fee to continue.')

      click_on 'Pay for 1 month'

      # He must be re-directed to the payment's long_url.
      expect(page).to have_content("Instamojo.open('#{long_url}');")

      # His startup should now have a payment with the right amount.
      expect(payment.reload.amount).to eq(2000.0)

      # Mimic a successful payment, by redirecting to Instamojo redirect URL.
      visit instamojo_redirect_path(payment_request_id: payment.instamojo_payment_request_id, payment_id: 'PAYMENT_ID')

      # User should be redirected to dashboard after processing.
      expect(page).to have_content('Pivot your startup journey!')

      # Payment target should now be marked complete.
      fee_payment_status = Targets::StatusService.new(fee_payment_target, founder).status
      expect(fee_payment_status).to eq(Targets::StatusService::STATUS_COMPLETE)

      # He should now also have a referral coupon.
      expect(startup.referral_coupon).to_not eq(nil)
    end

    scenario 'He completes payment applying a referral coupon' do
      sign_in_user founder.user, referer: fee_founder_path

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

      click_on 'Pay for 1 month'

      expect(page).to have_content("Instamojo.open('#{long_url}');")

      # Store the current billing_end_at for referrer.
      referrer_end_date = referrer_payment.billing_end_at

      # Mimic a successful payment, by redirecting to Instamojo redirect URL.
      visit instamojo_redirect_path(payment_request_id: payment.reload.instamojo_payment_request_id, payment_id: 'PAYMENT_ID')

      # User should be redirected to dashboard after processing.
      expect(page).to have_content('Pivot your startup journey!')

      # The coupon usage must be now marked redeemed for the startup.
      expect(startup.reload.coupon_usage.redeemed_at).to_not eq(nil)

      # The user and referrer should have received 15 and 10 days subscription extension respectively.
      expect(payment.reload.billing_end_at.beginning_of_minute).to eq((Time.zone.now + 1.month + 15.days).beginning_of_minute)
      expect(referrer_payment.reload.billing_end_at.beginning_of_minute).to eq((referrer_end_date + 10.days).beginning_of_minute)

      # The referrer should have received an email informing of his/her reward.
      open_email(referrer_startup.team_lead.email)
      expect(current_email.subject).to include('Your startup has unlocked SV.CO referral rewards!')
    end

    context 'when there are confirmed and unconfirmed founders' do
      # Add two more, one unconfirmed. Total is four, at this point.
      let!(:confirmed_founder) { create :founder, startup: startup }
      let!(:unconfirmed_founder) { create :founder, invited_startup: startup }

      scenario 'logged in founder needs to pay for both confirmed and unconfirmed founders' do
        sign_in_user founder.user, referer: fee_founder_path

        within('.fee-offer__box', text: '1 month') do
          expect(page).to have_content('₹4000 for 4 founders')
        end
      end
    end
  end

  context 'Founder has an incomplete, requested payment request' do
    let!(:payment) { create :payment, :requested, startup: startup, amount: 2000 }

    before do
      complete_target founder, screening_target
      startup.founders << create(:founder)
      startup.founders << create(:founder)
      complete_target founder, cofounder_addition_target
    end

    scenario 'Founder resubmits the payment form' do
      sign_in_user founder.user, referer: fee_founder_path

      expect(page).to have_content("It looks like you've attempted to pay at least once before, but didn't complete the process.")

      # Stub the request to disable previous payment.
      stub_request(:post, "https://www.example.com/payment-requests/#{payment.instamojo_payment_request_id}/disable/")
        .to_return(body: { success: true }.to_json)

      # Stub the request to create new payment.
      stub_request(:post, 'https://www.example.com/payment-requests/')
        .with(body: hash_including(
          amount: '6000.0',
          buyer_name: founder.name,
          email: founder.email,
          purpose: 'Fee for SV.CO'
        ))
        .to_return(body: {
          success: true,
          payment_request: {
            id: 'NEW_ID',
            status: 'Pending',
            shorturl: 'https://example.com/short',
            longurl: long_url
          }
        }.to_json)

      # He chooses another period.
      click_on 'Pay for 3 months'

      expect(page).to have_content("Instamojo.open('#{long_url}');")

      # The payment should have been updated.
      expect(payment.reload.instamojo_payment_request_id).to eq('NEW_ID')
    end
  end
end
