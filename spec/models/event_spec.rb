require 'spec_helper'

describe Event do
  context 'update a Event as featured' do
    it 'sends push if assign event item as featured for first time' do
      event = build(:event)
      event.save
      allow(event).to receive(:send_push_notification).and_return(true)
      expect(event).to receive(:send_push_notification)
      event.update_attributes!(featured: true)
    end

    it "doesn't sends push if event item is reassigned as featured" do
      event = create(:event, notification_sent: true)
      allow(event).to receive(:send_push_notification).and_return(true)
      expect(event).not_to receive(:send_push_notification)
      event.update_attributes!(featured: true)
    end
  end
end
