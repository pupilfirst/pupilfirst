require 'rails_helper'

describe MentorMeetingsCleanupJob, type: :job do
  describe '.perform' do
    context 'when a requested meeting request has timed out' do
      let!(:meeting) { create :mentor_meeting, suggested_meeting_at: 10.minute.ago, status: MentorMeeting::STATUS_REQUESTED }

      it 'expires the meeting' do
        MentorMeetingsCleanupJob.perform_now
        meeting.reload
        expect(meeting.status).to eq(MentorMeeting::STATUS_EXPIRED)
      end
    end

    context 'when a rescheduled meeting request has timed out' do
      let!(:meeting) { create :mentor_meeting, suggested_meeting_at: 10.minute.ago, status: MentorMeeting::STATUS_RESCHEDULED }

      it 'expires the meeting' do
        MentorMeetingsCleanupJob.perform_now
        meeting.reload
        expect(meeting.status).to eq(MentorMeeting::STATUS_EXPIRED)
      end
    end

    context 'when an accepted meeting request has timed out' do
      let!(:meeting) { create :mentor_meeting, suggested_meeting_at: 10.minutes.from_now, meeting_at: 10.minute.ago, status: MentorMeeting::STATUS_ACCEPTED }

      it 'expires the meeting' do
        MentorMeetingsCleanupJob.perform_now
        meeting.reload
        expect(meeting.status).to eq(MentorMeeting::STATUS_EXPIRED)
      end
    end

    context 'when a meeting was started last day' do
      let!(:meeting) { create :mentor_meeting, meeting_at: 1.day.ago, status: MentorMeeting::STATUS_STARTED }

      it 'sets meeting to completed' do
        MentorMeetingsCleanupJob.perform_now
        meeting.reload
        expect(meeting.status).to eq(MentorMeeting::STATUS_COMPLETED)
      end
    end
  end
end
