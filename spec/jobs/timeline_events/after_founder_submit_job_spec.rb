require 'rails_helper'

describe TimelineEvents::AfterFounderSubmitJob do
  subject { described_class }

  let(:mock_service) { instance_double(MarkAsImprovedTargetService) }

  describe '#perform' do
    it 'sends diff to author of timeline event' do
      expect(MarkAsImprovedTargetService).to receive(:new).and_return(mock_service)
      expect(mock_message_service).to receive(:something).with(arguments)

      # More?

      subject.perform_now(timeline_event, old_description)
    end
  end
end
