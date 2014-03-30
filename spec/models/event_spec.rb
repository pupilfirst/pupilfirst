require 'spec_helper'

describe Event do
  context 'update a Event as featured' do
    it "sends push if assign event item as featured for first time" do
      event = build(:event)
      event.save
      event.stub(:send_push_notification).and_return(true)
      expect(event).to receive(:send_push_notification)
      event.update_attributes!(featured: true)
    end

    it "dosn't sends push if event item is re-asigned as featured" do
      event = create(:event, notification_sent: true)
      event.stub(:send_push_notification).and_return(true)
      expect(event).not_to receive(:send_push_notification)
      event.update_attributes!(featured: true)
    end
  end
end
