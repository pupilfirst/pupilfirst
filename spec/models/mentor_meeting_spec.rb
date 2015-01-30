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
    let(:comment) { Faker::Lorem.words(5).join ' ' }

    it 'sets stores rejected status and comment' do
      subject.reject!(comment)
      expect(subject.status).to eq(MentorMeeting::STATUS_REJECTED)
      expect(subject.mentor_comments).to eq(comment)
    end

    it 'sends rejection message' do
      expect(subject).to receive(:send_rejection_message)
      subject.reject!(comment)
    end
  end

  describe '#accept' do
    subject { create :mentor_meeting }
    let(:new_meeting_at) { 1.day.from_now }

    it 'sets stores accepted status and meeting time' do
      subject.accept!(new_meeting_at)
      expect(subject.status).to eq(MentorMeeting::STATUS_ACCEPTED)
      expect(subject.meeting_at).to eq(new_meeting_at)
    end

    it 'sends acceptance message' do
      expect(subject).to receive(:send_acceptance_message)
      subject.accept!(new_meeting_at)
    end
  end
end
