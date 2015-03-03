require 'spec_helper'

RSpec.describe MeetingDayReminderJob, :type => :job do
  describe '.perform' do
  	context 'when a meeting is scheduled for today' do
  		let!(:meeting) { create :mentor_meeting, meeting_at: Time.now}
  		it 'sends user and mentor reminder emails' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(MentoringMailer).to receive(:meeting_today_user).with(meeting).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        MeetingDayReminderJob.perform_now
      end
    end
  end
end
