require 'rails_helper'

describe FacultyModule::WeeklySlotsPromptJob do
  subject { described_class }

  let!(:faculty_non_self_service) { create :faculty, :connectable, self_service: false }
  let!(:faculty_self_service) { create :faculty, :connectable, self_service: true }
  let!(:faculty_inactive) { create :faculty, :connectable, self_service: true, inactive: true }

  before do
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_non_self_service
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_self_service
    create :connect_slot, slot_at: 1.5.weeks.ago, faculty: faculty_inactive
  end

  describe '#perform' do
    it 'copies weekly slots for active faculty with self service and mails him about it' do
      described_class.perform_now

      expect(faculty_non_self_service.connect_slots.count).to eq(1)
      expect(faculty_self_service.connect_slots.count).to eq(2)
      expect(faculty_inactive.connect_slots.count).to eq(1)

      open_email(faculty_self_service.email)

      expect(current_email).to have_content('Please review your office hour slots for the next week.')
    end
  end
end
