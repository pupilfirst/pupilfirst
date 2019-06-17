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

  it 'cleans up orphaned timeline event files' do
    # Unorphaned timeline event files.
    submission = create :timeline_event
    tef_1 = create :timeline_event_file, timeline_event: submission, created_at: 1.week.ago

    # Orphaned timeline events.
    tef_2 = create :timeline_event_file, timeline_event: nil, created_at: 1.hour.ago
    create :timeline_event_file, timeline_event: nil, created_at: 25.hours.ago

    expect do
      subject.perform_now
    end.to change { TimelineEventFile.count }.from(3).to(2)

    expect(TimelineEventFile.all.pluck(:id)).to contain_exactly(tef_1.id, tef_2.id)
  end
end
