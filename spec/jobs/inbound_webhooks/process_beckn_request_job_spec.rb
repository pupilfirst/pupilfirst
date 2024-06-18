require "rails_helper"

RSpec.describe InboundWebhooks::ProcessBecknRequestJob, type: :job do
  include ActiveJob::TestHelper

  let(:body_data) { { context: { action: "search" } }.to_json }
  let!(:inbound_webhook) { create(:inbound_webhook, body: body_data) }

  before do
    allow(InboundWebhook).to receive(:new).and_return(inbound_webhook)
    allow(inbound_webhook).to receive_messages(
      processing!: nil,
      processed!: nil,
      failed!: nil,
    )
  end

  describe "#perform" do
    context "when the action is valid" do
      let(:service_instance) do
        instance_double("Beckn::Api::OnSearchDataService", execute: {})
      end
      let(:response) { instance_double("Net::HTTPSuccess", is_a?: true) }

      before do
        allow(Beckn::Api::OnSearchDataService).to receive(:new).and_return(
          service_instance,
        )
        allow(Beckn::RespondService).to receive(:new).and_return(
          instance_double("Beckn::RespondService", execute: response),
        )
      end

      it "processes the webhook successfully" do
        described_class.perform_now(inbound_webhook)
        expect(inbound_webhook).to have_received(:processed!)
      end
    end

    context "when the action is unknown" do
      let(:body_data) { { context: { action: "unknown" } }.to_json }

      it "fails the webhook" do
        described_class.perform_now(inbound_webhook)
        expect(inbound_webhook).to have_received(:failed!)
      end
    end

    context "when JSON parsing fails" do
      let(:body_data) { "invalid json" }

      before do
        allow(JSON).to receive(:parse).with(body_data).and_raise(
          JSON::ParserError,
        )
      end

      it "logs an error and marks the webhook as failed" do
        described_class.perform_now(inbound_webhook)
        expect(inbound_webhook).to have_received(:failed!)
      end
    end
  end
end
