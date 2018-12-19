require 'rails_helper'

RSpec.describe FacultyCourseEnrollment, type: :model do
  describe 'creation' do
    let(:faculty) { create :faculty }
    let(:course) { create :course }

    context 'when safe_to_create is not set' do
      it 'fails validation' do
        enrollment = described_class.create(faculty: faculty, course: course)
        expect(enrollment.errors.to_a).to include('is not safe to create')
        expect(enrollment.persisted?).to eq(false)
      end
    end

    context 'when safe_to_create is set' do
      it 'passes validation' do
        enrollment = described_class.create(faculty: faculty, course: course, safe_to_create: true)
        expect(enrollment.persisted?).to eq(true)
      end
    end
  end
end
