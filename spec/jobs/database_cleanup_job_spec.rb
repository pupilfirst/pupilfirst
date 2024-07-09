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

  it "cleans up expired authentication tokens" do
    # Some recent tokens
    at_1 = create :authentication_token
    at_2 = create :authentication_token, expires_at: 1.minute.from_now
    at_3 = create :authentication_token, :url_token
    at_4 = create :authentication_token, :api_token

    # Two expired token.
    create :authentication_token, :api_token, expires_at: 1.minute.ago
    create :authentication_token, :url_token, expires_at: 10.minutes.ago

    expect { subject.perform_now }.to change { AuthenticationToken.count }.from(
      6
    ).to(4)

    expect(AuthenticationToken.pluck(:id)).to contain_exactly(
      at_1.id,
      at_2.id,
      at_3.id,
      at_4.id
    )
  end

  it "cleans up old failed input token attempts" do
    fita_1 = create :failed_input_token_attempt
    fita_2 = create :failed_input_token_attempt, created_at: 23.hours.ago

    # This one should be cleaned up.
    create :failed_input_token_attempt, created_at: 25.hours.ago

    expect { subject.perform_now }.to change {
      FailedInputTokenAttempt.count
    }.from(3).to(2)

    expect(FailedInputTokenAttempt.pluck(:id)).to contain_exactly(
      fita_1.id,
      fita_2.id
    )
  end
end
