require 'rails_helper'

describe DatabaseCleanupJob do
  subject { described_class }

  it 'cleans up orphaned timeline event files' do
    # Unorphaned timeline event files.
    submission = create :timeline_event
    tef_1 =
      create :timeline_event_file,
             timeline_event: submission,
             created_at: 1.week.ago

    # Orphaned timeline events.
    tef_2 =
      create :timeline_event_file, timeline_event: nil, created_at: 1.hour.ago
    create :timeline_event_file, timeline_event: nil, created_at: 25.hours.ago

    expect { subject.perform_now }.to change { TimelineEventFile.count }
      .from(3)
      .to(2)

    expect(TimelineEventFile.all.pluck(:id)).to contain_exactly(
      tef_1.id,
      tef_2.id
    )
  end
end
