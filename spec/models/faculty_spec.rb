require 'rails_helper'

RSpec.describe Faculty, type: :model do
  let!(:faculty) { create :faculty }
  let!(:connect_slot) { create :connect_slot }

  describe '.valid_categories' do
    it 'returns valid categories' do
      categories = Faculty.valid_categories
      expect(categories.count).to eq(3)
      expect(categories - [Faculty::CATEGORY_TEAM, Faculty::CATEGORY_ADVISORY_BOARD, Faculty::CATEGORY_VISITING_FACULTY]).to be_empty
    end
  end

  describe '#copy_weekly_slots!' do
    it 'does not create slots if no previous connect slots available' do
      expect(faculty.connect_slots).to_not receive(:create!)
      faculty.copy_weekly_slots!
    end

    it 'does not creat slots if next week already has slots' do
      connect_slot.update!(faculty: faculty, slot_at: 7.days.from_now)
      expect(faculty.connect_slots).to_not receive(:create!)
      faculty.copy_weekly_slots!
    end

    it 'copies previous slot to next week if all is good' do
      connect_slot.update!(faculty: faculty, slot_at: 7.days.ago)
      expect(faculty.connect_slots).to receive(:create!).and_return(true)
      faculty.copy_weekly_slots!
    end
  end
end
