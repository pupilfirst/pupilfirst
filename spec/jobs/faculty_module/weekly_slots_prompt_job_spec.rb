require 'rails_helper'

describe FacultyModule::WeeklySlotsPromptJob do
  subject { described_class }

  let!(:faculty_non_self_service) { create :faculty, self_service: false, notify_for_submission: true }
  let!(:faculty_self_service) { create :faculty, self_service: true, notify_for_submission: true }
  let!(:another_faculty) { create :faculty, self_service: true }

  before do
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_non_self_service
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_self_service
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: another_faculty

    # Create a domain for school
    create :domain, :primary, school: faculty_self_service.school
  end

  describe '#perform' do
    it 'copies weekly slots for faculty with self service and mails him about it' do
      described_class.perform_now

      expect(faculty_non_self_service.connect_slots.count).to eq(1)
      expect(faculty_self_service.connect_slots.count).to eq(2)
      expect(another_faculty.connect_slots.count).to eq(1)

      open_email(faculty_self_service.email)

      expect(current_email).to have_content('Please review your connect session slots for the next week.')
    end
  end
end
