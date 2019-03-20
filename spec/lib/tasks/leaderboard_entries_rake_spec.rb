require 'rails_helper'

describe "leaderboard_entries:create" do
  include_context "rake"

  let(:course) { create :course, name: course_name }
  let(:course_name) { Faker::Lorem.word }
  let(:week_start) { double(ActiveSupport::TimeWithZone) }
  let(:week_end) { double(ActiveSupport::TimeWithZone) }
  let(:lts) { instance_double(LeaderboardTimeService, week_start: week_start, week_end: week_end) }
  let(:cles) { instance_double(Courses::CreateLeaderboardEntriesService) }

  before do
    allow(LeaderboardTimeService).to receive(:new).and_return(lts)
    allow(Courses::CreateLeaderboardEntriesService).to receive(:new).with(course).and_return(cles)
  end

  it 'should have environment in prerequisites' do
    expect(subject.prerequisites).to include('environment')
  end

  context "when course name isn't supplied" do
    it 'raises error' do
      expect { subject.invoke }.to raise_error('Course name is required as argument')
    end
  end

  context 'when course name is supplied' do
    it 'invokes Courses::CreateLeaderboardEntriesService' do
      expect(cles).to receive(:execute).with(week_start, week_end)
      subject.invoke(course_name)
    end
  end
end
