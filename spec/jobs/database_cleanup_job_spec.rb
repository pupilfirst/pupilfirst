require 'rails_helper'

describe DatabaseCleanupJob do
  subject { described_class }

  it 'cleans up stale connect slots' do
    # Stale slots
    create :connect_slot, slot_at: 1.5.weeks.ago
    create :connect_slot, slot_at: 1.month.ago

    # Old, used slot.
    used_slot = create :connect_slot, slot_at: 1.month.ago
    create :connect_request, connect_slot: used_slot

    # Recent slots.
    future_slot = create :connect_slot
    recent_past_slot = create :connect_slot, slot_at: 2.days.ago

    subject.perform_now

    expect(ConnectSlot.all.pluck(:id) - [used_slot.id, future_slot.id, recent_past_slot.id]).to be_empty
  end
end
