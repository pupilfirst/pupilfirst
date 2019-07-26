require 'rails_helper'

describe FacultyModule::WeeklySlotsPromptJob do
  subject { described_class }

  let!(:school) { create :school, :current }
  let!(:faculty_non_self_service) { create :faculty, school: school, self_service: false }
  let!(:faculty_self_service) { create :faculty, school: school, self_service: true }
  let!(:another_faculty) { create :faculty, school: school, self_service: true }

  before do
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_non_self_service
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_self_service
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: another_faculty
  end

  describe '#perform' do
    it 'copies weekly slots for faculty with self service and mails him about it' do
      described_class.perform_now

      expect(faculty_non_self_service.connect_slots.count).to eq(1)
      expect(faculty_self_service.connect_slots.count).to eq(2)
      expect(another_faculty.connect_slots.count).to eq(2)

      open_email(faculty_self_service.email)

      expect(current_email).to have_content('Please review your connect session slots for the next week.')
    end
  end
end
