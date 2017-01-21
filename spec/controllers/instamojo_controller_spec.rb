require 'rails_helper'

describe InstamojoController do
  let(:payment_stage) { create :application_stage, :payment }
  let!(:coding_stage) { create :application_stage, :coding }

  let(:application_round) { create :application_round, :screening_stage }
  let(:batch_application) { create :batch_application, application_stage: payment_stage, application_round: application_round }
  let(:instamojo_payment_request_id) { SecureRandom.hex }
  let(:long_url) { Faker::Internet.url }
  let(:short_url) { Faker::Internet.url }

  let(:payment) do
    create :payment,
      batch_application: batch_application,
      batch_applicant: batch_application.team_lead,
      amount: batch_application.fee,
      instamojo_payment_request_id: instamojo_payment_request_id,
      instamojo_payment_request_status: 'Pending',
      short_url: short_url,
      long_url: long_url
  end

  let(:payment_id) { SecureRandom.hex }

  describe 'GET redirect' do
    before do
      allow_any_instance_of(Instamojo).to receive(:payment_details).with(
        payment_request_id: instamojo_payment_request_id,
        payment_id: payment_id
      ).and_return(
        payment_request_status: 'Completed',
        payment_status: 'Credit',
        fees: '123.45'
      )
    end

    it 'updates payment and associated entries' do
      get :redirect, params: { payment_request_id: payment.instamojo_payment_request_id, payment_id: payment_id }

      payment.reload

      expect(payment.instamojo_payment_id).to eq(payment_id)
      expect(payment.instamojo_payment_request_status).to eq('Completed')
      expect(payment.instamojo_payment_status).to eq('Credit')
      expect(payment.fees).to eq(123.45)

      # Expect the application to have moved to coding stage.
      expect(payment.batch_application.application_stage).to eq(ApplicationStage.coding_stage)
    end

    it 'redirects to continue page with a from parameter' do
      get :redirect, params: { payment_request_id: payment.instamojo_payment_request_id, payment_id: payment_id }
      expect(response).to redirect_to(apply_continue_path(from: 'instamojo'))
    end
  end

  describe 'POST webhook' do
    it 'updates payment and associated entries' do
      data = "43.21|#{payment_id}|#{payment.instamojo_payment_request_id}|Credit"
      digest = OpenSSL::Digest.new('sha1')
      computed_mac = OpenSSL::HMAC.hexdigest(digest, 'TEST_SALT', data)

      post :webhook, params: {
        payment_request_id: payment.instamojo_payment_request_id,
        payment_id: payment_id,
        status: 'Credit',
        fees: '43.21',
        mac: computed_mac
      }

      payment.reload

      expect(payment.instamojo_payment_id).to eq(payment_id)
      expect(payment.instamojo_payment_request_status).to eq('Completed')
      expect(payment.instamojo_payment_status).to eq('Credit')
      expect(payment.fees).to eq(43.21)

      # Expect the application to have moved to coding stage.
      expect(payment.batch_application.application_stage).to eq(ApplicationStage.coding_stage)
    end

    context 'when mac is incorrect or missing' do
      it 'returns 401 Unauthorized' do
        post :webhook, params: {
          payment_request_id: payment.instamojo_payment_request_id,
          payment_id: payment_id,
          status: 'Credit',
          fees: '43.21'
        }

        expect(response.status).to eq(401)
      end
    end
  end
end
