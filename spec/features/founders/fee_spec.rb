require 'rails_helper'

feature 'Founder Monthly Fee Payment' do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:founder) { startup.team_lead }
  let(:long_url) { 'https://example.com/long' }

  context 'when there is no pending payment' do
    scenario 'founder visits fee payment page' do
      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end

  context 'when there is a pending payment' do
    let!(:payment) { create :payment, startup: startup, amount: 2000 }

    before do
      stub_request(:post, 'https://www.example.com/payment-requests/')
        .with(body: hash_including(
          amount: '2000.0',
          buyer_name: startup.team_lead.name,
          email: startup.team_lead.email
        ))
        .to_return(body: {
          success: true,
          payment_request: {
            id: 'ID',
            status: 'Pending',
            shorturl: 'https://example.com/short',
            longurl: long_url
          }
        }.to_json)
    end

    scenario 'founder attempts payment' do
      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee to continue.')
      click_button 'Pay for 1 month'
      expect(page).to have_content({ long_url: long_url }.to_json)
    end

    scenario 'non-admin visits fee page' do
      non_admin_founder = startup.founders.where.not(id: startup.team_lead_id).first
      sign_in_user non_admin_founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee to continue.')
    end
  end

  context 'when there is a pending requested payment' do
    let!(:payment) { create :payment, :requested, startup: startup, amount: 4000 }

    scenario 'founder attempts payment again with different period' do
      # Stub the call to disable old payment request.
      stub_request(:post, "https://www.example.com/payment-requests/#{payment.instamojo_payment_request_id}/disable/")
        .to_return(body: { success: true }.to_json)

      # Stub the call to create new payment request.
      stub_request(:post, 'https://www.example.com/payment-requests/')
        .with(body: hash_including(
          allow_repeated_payments: 'false',
          amount: '4000.0',
          buyer_name: startup.team_lead.name,
          email: startup.team_lead.email,
          purpose: 'Fee for SV.CO',
          redirect_url: 'http://localhost:3000/instamojo/redirect',
          send_email: 'false',
          send_sms: 'false'
        ))
        .to_return(
          body: {
            success: true,
            payment_request: {
              id: 'NEW_ID',
              status: 'Pending',
              shorturl: 'https://example.com/short',
              longurl: long_url
            }
          }.to_json
        )

      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee to continue.')
      expect(page).to have_content("It looks like you've attempted to pay at least once before")
      click_button 'Pay for 3 months'
      expect(page).to have_content({ long_url: long_url }.to_json)
      expect(payment.reload.instamojo_payment_request_id).to eq('NEW_ID')
    end

    scenario 'founder attempts payment again with same period' do
      # Stub the call to validate existing payment reqeust.
      stub_request(:get, "https://www.example.com/payment-requests/#{payment.instamojo_payment_request_id}/")
        .to_return(body: {
          success: true,
          payment_request: {
            status: 'Pending',
            shorturl: payment.short_url,
            redirect_url: '',
            webhook: ''
          }
        }.to_json)

      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee to continue.')
      expect(page).to have_content("It looks like you've attempted to pay at least once before")
      click_button 'Pay for 1 month'
      expect(page).to have_content({ long_url: payment.long_url }.to_json)
    end
  end
end
