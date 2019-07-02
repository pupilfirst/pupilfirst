require 'rails_helper'

describe "leaderboard_entries:create" do
  include_context "rake"

  let!(:enabled_course) { create :course, enable_leaderboard: true }
  let!(:disabled_course) { create :course }
  let(:week_start) { double(ActiveSupport::TimeWithZone) }
  let(:week_end) { double(ActiveSupport::TimeWithZone) }
  let(:lts) { instance_double(LeaderboardTimeService, week_start: week_start, week_end: week_end) }
  let(:cles) { instance_double(Courses::CreateLeaderboardEntriesService) }

  before do
    allow(LeaderboardTimeService).to receive(:new).and_return(lts)
    allow(Courses::CreateLeaderboardEntriesService).to receive(:new).with(enabled_course).and_return(cles)
  end

  it 'should have environment in prerequisites' do
    expect(subject.prerequisites).to include('environment')
  end

  it 'invokes Courses::CreateLeaderboardEntriesService for leaderboard-enabled courses and ignores disabled ones' do
    expect(Courses::CreateLeaderboardEntriesService).not_to receive(:new).with(disabled_course)
    expect(cles).to receive(:execute).with(week_start, week_end)
    subject.invoke
  end
end
