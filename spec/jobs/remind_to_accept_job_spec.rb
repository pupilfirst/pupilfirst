require 'spec_helper'

RSpec.describe MeetingDayReminderJob, :type => :job do
  describe '.perform' do

    context 'when a meeting request is pending 2 days before tentative schedule' do
  		let!(:meeting) { create :mentor_meeting, suggested_meeting_at: 1.day.from_now, status: MentorMeeting::STATUS_REQUESTED}
  		it 'sends mentor reminder email to accept' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(MentoringMailer).to receive(:remind_mentor_to_accept).with(meeting).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        RemindToAcceptJob.perform_now
      end
    end

    context 'when a meeting reschedule is pending 2 days before tentatvie schedule' do
      let!(:meeting) { create :mentor_meeting, suggested_meeting_at: 1.day.from_now, status: MentorMeeting::STATUS_RESCHEDULED}
      it 'sends user reminder email to accept' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(MentoringMailer).to receive(:remind_user_to_accept).with(meeting).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        RemindToAcceptJob.perform_now
      end
    end

  end
end
