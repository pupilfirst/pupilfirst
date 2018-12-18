require 'rails_helper'

RSpec.describe FacultyStartupEnrollment, type: :model do
  describe 'creation' do
    let(:faculty) { create :faculty }
    let(:startup) { create :startup }

    context 'when safe_to_create is not set' do
      it 'fails validation' do
        enrollment = described_class.create(faculty: faculty, startup: startup)
        expect(enrollment.errors.to_a).to include('is not safe to create')
        expect(enrollment.persisted?).to eq(false)
      end
    end

    context 'when safe_to_create is set' do
      it 'passes validation' do
        enrollment = described_class.create(faculty: faculty, startup: startup, safe_to_create: true)
        expect(enrollment.persisted?).to eq(true)
      end
    end
  end
end
