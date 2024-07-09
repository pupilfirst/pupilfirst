require "rails_helper"

describe DatabaseCleanupJob do
  subject { described_class }

  it "cleans up orphaned timeline event files" do
    # Unorphaned timeline event files.
    submission = create :timeline_event

    # A file linked to a timeline event - shouldn't be deleted.
    tef_1 =
      create :timeline_event_file,
             timeline_event: submission,
             created_at: 1.week.ago

    # An unlinked timeline event, created just an hour ago - shouldn't be deleted.
    tef_2 =
      create :timeline_event_file, timeline_event: nil, created_at: 1.hour.ago

    # An unlinked timeline event, created just an hour ago - SHOULD be deleted.
    create :timeline_event_file, timeline_event: nil, created_at: 25.hours.ago

    expect { subject.perform_now }.to change { TimelineEventFile.count }.from(
      3
    ).to(2)

    expect(TimelineEventFile.pluck(:id)).to contain_exactly(tef_1.id, tef_2.id)
  end
end
