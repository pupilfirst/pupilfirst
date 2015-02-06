require 'spec_helper'

describe Event do
  subject { create :event }

  context 'update a Event as featured' do
    before do
      allow(subject).to receive(:send_push_notification!).and_return(true)
    end

    it 'sends push if assign event item as featured for first time' do
      expect(subject).to receive(:send_push_notification!)
      subject.update_attributes!(featured: true)
    end

    context 'when notification has already been sent' do
      subject { create(:event, notification_sent: true) }

      it "doesn't sends push if event item is reassigned as featured" do
        expect(subject).not_to receive(:send_push_notification!)
        subject.update_attributes!(featured: true)
      end
    end
  end
end
