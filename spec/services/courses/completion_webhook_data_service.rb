require 'rails_helper'

describe Courses::CompletionWebhookDataService do
  subject { described_class.new(course, student) }
  let(:course) { create :course, :with_cohort }
  let(:level) { create :level, course: course }
  let(:student) { create :student, level: level, cohort: course.cohorts.first }

  describe '#data' do
    it 'returns data appropriate for sending via webhook' do
      data = subject.data

      expect(data[:course_id]).to eq(course.id)
      expect(data[:course_name]).to eq(course.name)
      expect(data[:student_name]).to eq(student.name)
      expect(data[:student_email]).to eq(student.email)
    end
  end
end
