require 'spec_helper'

RSpec.describe MeetingFeedbackReminderJob, :type => :job do
  describe '.perform' do
  	context 'when a meeting completed last week has no user rating' do
  		let!(:meeting) { create :mentor_meeting, meeting_at: 8.days.ago, status: MentorMeeting::STATUS_COMPLETED, user_rating:nil}
  		it 'sends user reminder email for feedback' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(MentoringMailer).to receive(:meeting_feedback_user).with(meeting).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        MeetingFeedbackReminderJob.perform_now
      end
    end

    context 'when a meeting completed last week has no mentor rating' do
      let!(:meeting) { create :mentor_meeting, meeting_at: 8.days.ago, status: MentorMeeting::STATUS_COMPLETED, mentor_rating:nil}
      it 'sends user reminder email for feedback' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(MentoringMailer).to receive(:meeting_feedback_mentor).with(meeting).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        MeetingFeedbackReminderJob.perform_now
      end
    end
  end
end
