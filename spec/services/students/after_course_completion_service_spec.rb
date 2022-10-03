require 'rails_helper'

describe Students::AfterCourseCompletionService do
  let(:student) { create :student }

  describe '#execute' do
    it 'publishes course_completed event' do
      notification_service = instance_double('Developers::NotificationService')
      expect(notification_service).to receive(:execute).with(
        student.course,
        :course_completed,
        student.user,
        student.course
      )
      subject =
        described_class.new(student, notification_service: notification_service)
      subject.execute

      expect(student.completed_at).not_to be_nil
    end
  end
end
