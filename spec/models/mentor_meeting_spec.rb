require 'spec_helper'

describe MentorMeeting do
  describe '#start!' do
    subject { create :mentor_meeting, status: MentorMeeting::STATUS_ACCEPTED, meeting_at: 10.minutes.from_now }

    it 'sets status to started' do
      subject.start!
      expect(subject.status).to eq(MentorMeeting::STATUS_STARTED)
    end
  end

  describe '#reject' do
    subject { create :mentor_meeting }

    let(:meeting_for_mentor) {
      {
        mentor_comments: Faker::Lorem.words(5).join(' ')
      }.with_indifferent_access
    }

    let(:meeting_for_user) {
      {
        user_comments: Faker::Lorem.words(5).join(' ')
      }.with_indifferent_access
    }

    it 'sets stores rejected status and comment as mentor' do
      subject.reject!(meeting_for_mentor,"mentor")
      expect(subject.status).to eq(MentorMeeting::STATUS_REJECTED)
      expect(subject.mentor_comments).to eq(meeting_for_mentor["mentor_comments"])
    end

    it 'sends rejection message as mentor' do
      expect(subject).to receive(:send_rejection_message)
      subject.reject!(meeting_for_mentor,"mentor")
    end

    it 'sets stores rejected status and comment as user' do
      subject.reject!(meeting_for_user,"user")
      expect(subject.status).to eq(MentorMeeting::STATUS_REJECTED)
      expect(subject.user_comments).to eq(meeting_for_user["user_comments"])
    end

    it 'sends rejection message as user' do
      expect(subject).to receive(:send_rejection_message)
      subject.reject!(meeting_for_user,"user")
    end

  end

  describe '#accept' do
    subject { create :mentor_meeting }
    let(:meeting) {
      {
        suggested_meeting_at: Time.now
      }.with_indifferent_access
    }

    it 'sets stores accepted status and meeting time as user' do
      subject.accept!(meeting,"user")
      expect(subject.status).to eq(MentorMeeting::STATUS_ACCEPTED)
      expect(subject.meeting_at).to eq(meeting["suggested_meeting_at"])
    end

    it 'sets stores accepted status and meeting time as mentor' do
      subject.accept!(meeting,"mentor")
      expect(subject.status).to eq(MentorMeeting::STATUS_ACCEPTED)
      expect(subject.meeting_at).to eq(meeting["suggested_meeting_at"])
    end

    it 'sends acceptance message as mentor' do
      expect(subject).to receive(:send_acceptance_message)
      subject.accept!(meeting,"mentor")
    end

    it 'sends acceptance message as user' do
      expect(subject).to receive(:send_acceptance_message)
      subject.accept!(meeting,"user")
    end

  end
end
