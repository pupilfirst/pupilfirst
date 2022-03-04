require 'rails_helper'

describe Courses::CompletionWebhookDataService do
  subject { described_class.new(course, user) }
  let(:course) { create :course }
  let(:level) { create :level, course: course }
  let(:startup) { create :startup, level: level }
  let(:user) { startup.founders.first }

  describe '#data' do
    it 'returns data appropriate for sending via webhook' do
      data = subject.data

      expect(data[:course_id]).to eq(course.id)
      expect(data[:course_name]).to eq(course.name)
      expect(data[:student_name]).to eq(user.name)
      expect(data[:student_email]).to eq(user.email)
    end
  end
end
