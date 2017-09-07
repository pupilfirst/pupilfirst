require 'rails_helper'

feature 'Founder Monthly Fee Payment' do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:founder) { startup.team_lead }

  context 'when there is no pending payment' do
    scenario 'founder visits fee payment page' do
      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end

  context 'when there is a pending payment' do
    let!(:payment) { create :payment, startup: startup, amount: 2000 }
    let(:long_url) { 'https://example.com/long' }

    before do
      # Mock the Instamojo call
      Rails.application.secrets.instamojo_url = 'https://www.example.com'

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

    after do
      Rails.application.secrets.instamojo_url = ENV['INSTAMOJO_API_URL']
    end

    scenario 'founder attempts payment' do
      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee for the next month.')
      click_button 'Pay Now'
      expect(page).to have_content("Instamojo.open('#{long_url}');")
    end

    scenario 'non-admin visits fee page' do
      non_admin_founder = startup.founders.where.not(id: startup.team_lead_id).first
      sign_in_user non_admin_founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee for the next month.')
    end
  end

  context 'when there is a pending requested payment' do
    let!(:payment) { create :payment, :requested, startup: startup, amount: 4000 }

    before do
      # Mock the Instamojo call
      Rails.application.secrets.instamojo_url = 'https://www.example.com'

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
    end

    after do
      Rails.application.secrets.instamojo_url = ENV['INSTAMOJO_API_URL']
    end

    scenario 'founder attempts payment again' do
      sign_in_user founder.user, referer: fee_founder_path
      expect(page).to have_content('Please pay the membership fee for the next month.')
      expect(page).to have_content("It looks like you've attempted to pay at least once before")
      click_button 'Pay Now'
      expect(page).to have_content("Instamojo.open('#{payment.long_url}');")
    end
  end
end
