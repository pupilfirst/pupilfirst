require 'rails_helper'

describe Faculty, type: :model do
  let!(:faculty) { create :faculty }

  describe '#copy_weekly_slots!' do
    context 'when no previous connect slots are available' do
      it 'does not create slots if no previous connect slots available' do
        expect { faculty.copy_weekly_slots! }.to_not change(ConnectSlot, :count)
      end
    end

    context 'when connect slot for previous week exists' do
      let!(:connect_slot) { create :connect_slot, faculty: faculty, slot_at: 7.days.ago }

      context 'when next neek already has slots' do
        let!(:connect_slot) { create :connect_slot, faculty: faculty, slot_at: 7.days.from_now }

        it 'does not creat slots' do
          connect_slot.update!(faculty: faculty, slot_at: 7.days.from_now)
          expect(faculty.connect_slots).to_not receive(:create!)
          expect { faculty.copy_weekly_slots! }.to_not change(ConnectSlot, :count)
        end
      end

      it 'copies previous slot to next week if all is good' do
        expect { faculty.copy_weekly_slots! }.to change(ConnectSlot, :count).by(1)
      end
    end
  end
end
