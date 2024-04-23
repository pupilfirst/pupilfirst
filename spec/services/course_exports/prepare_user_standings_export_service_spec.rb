require "rails_helper"

describe CourseExports::PrepareUserStandingsExportService do
  subject { described_class.new }

  let!(:user_1) { create(:user, email: "a@example.com") }
  let!(:user_2) { create(:user, email: "b@example.com") }
  let!(:user_3) { create(:user, email: "c@example.com") }
  let!(:user_ids) { [user_1.id, user_2.id, user_3.id] }

  let!(:school_admin) { create(:school_admin, school: user_1.school) }

  let!(:standing_1) { create(:standing, school: user_1.school, default: true) }
  let!(:standing_2) { create(:standing, school: user_1.school) }

  let!(:user_standing_1) do
    create(
      :user_standing,
      user: user_1,
      standing: standing_1,
      creator: school_admin.user,
      reason: "Reason 1",
      created_at: 4.days.ago
    )
  end

  let!(:user_standing_2) do
    create(
      :user_standing,
      user: user_1,
      standing: standing_2,
      creator: school_admin.user,
      reason: "Reason 2",
      created_at: 3.days.ago
    )
  end

  let!(:user_standing_3) do
    create(
      :user_standing,
      user: user_1,
      standing: standing_2,
      creator: school_admin.user,
      reason: "Reason 3",
      created_at: 2.days.ago,
      archived_at: 1.day.ago
    )
  end

  let!(:user_standing_4) do
    create(
      :user_standing,
      user: user_2,
      standing: standing_1,
      creator: school_admin.user,
      reason: "Reason 4",
      created_at: 1.day.ago
    )
  end

  let(:expected_data) do
    {
      title: "User Standings",
      rows: [
        [
          "User ID",
          "Email address",
          "Name",
          "Standing",
          "Log entry",
          "Created at",
          "Created by",
          "Archived at",
          "Archived by"
        ],
        [
          user_1.id,
          user_1.email,
          user_1.name,
          standing_2.name,
          user_standing_3.reason,
          user_standing_3.created_at.iso8601,
          school_admin.name,
          user_standing_3.archived_at&.iso8601,
          user_standing_3.archiver&.name
        ],
        [
          user_1.id,
          user_1.email,
          user_1.name,
          standing_2.name,
          user_standing_2.reason,
          user_standing_2.created_at.iso8601,
          school_admin.name,
          nil,
          nil
        ],
        [
          user_1.id,
          user_1.email,
          user_1.name,
          standing_1.name,
          user_standing_1.reason,
          user_standing_1.created_at.iso8601,
          school_admin.name,
          nil,
          nil
        ],
        [
          user_2.id,
          user_2.email,
          user_2.name,
          standing_1.name,
          user_standing_4.reason,
          user_standing_4.created_at.iso8601,
          school_admin.name,
          nil,
          nil
        ]
      ]
    }
  end

  before { user_1.school.update!(configuration: { enable_standing: true }) }

  it "returns the expected data" do
    expect(subject.execute(user_ids)).to eq(expected_data)
  end
end
