require 'rails_helper'

describe TimelineEvents::AfterFounderSubmitJob do
  subject { described_class }

  let(:faculty) { create :faculty, :with_email }
  let(:startup) { create :startup, :subscription_active }
  let(:timeline_event) { create :timeline_event, startup: startup }
  let(:mock_service) { instance_double(TimelineEvents::MarkAsImprovedTargetService, execute: nil) }

  describe '#perform' do
    before do
      allow(TimelineEvents::MarkAsImprovedTargetService).to receive(:new).and_return(mock_service)
    end

    it 'executes the MarkAsImprovedTargetService' do
      expect(mock_service).to receive(:execute)
      subject.perform_now(timeline_event)
    end

    context 'when the startup has a coach' do
      let(:startup) { create :startup, :sponsored, faculty: [faculty] }

      it 'sends a notification email to the coach' do
        subject.perform_now(timeline_event)

        open_email(faculty.email)

        expect(current_email.subject).to eq("There is a new submission from #{startup.product_name}")
        expect(current_email.body).to include('New Submission from Student')
        expect(current_email.body).to include("We have received a new submission from #{startup.team_lead.name}")
      end
    end

    context 'when the startup does not have a coach' do
      it 'does not send any emails' do
        subject.perform_now(timeline_event)

        open_email(faculty.email)

        expect(current_email).to be_nil
      end
    end
  end
end
