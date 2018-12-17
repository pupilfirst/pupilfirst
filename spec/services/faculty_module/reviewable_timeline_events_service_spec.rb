require 'rails_helper'

describe FacultyModule::ReviewableTimelineEventsService do
  include FounderSpecHelper

  subject { described_class.new(faculty) }

  let(:faculty) { create :faculty }
  let(:startup_1) { create :startup }
  let(:startup_2) { create :startup }
  let(:startup_3) { create :startup, level: startup_2.level }

  let(:level_s1) { startup_1.level }
  let(:level_s2) { startup_2.level }

  let(:target_group_s1) { create :target_group, milestone: true, level: level_s1 }
  let(:target_group_s2) { create :target_group, milestone: true, level: level_s2 }

  let(:target_s1_manual) { create :target, :for_startup, target_group: target_group_s1 }
  let(:target_s1_auto) { create :target, :for_startup, target_group: target_group_s1, submittability: Target::SUBMITTABILITY_AUTO_VERIFY }
  let(:target_s2) { create :target, :for_startup, target_group: target_group_s2 }

  # Submission from Startup 1, reviewed by faculty through course enrollment.
  let!(:reviewable_submission_1) { submit_target(startup_1.team_lead, target_s1_manual) }

  # Submission from Startup 1, for a target that is auto-verified.
  let!(:non_reviewable_submission_1) { complete_target(startup_1.team_lead, target_s1_auto) }

  # Submission from Startup 2, reviewed by faculty directly.
  let!(:reviewable_submission_2) { submit_target(startup_2.team_lead, target_s2) }

  # Submission from Startup 3, not reviewed by faculty directly, or through course.
  let!(:non_reviewable_submission_2) { submit_target(startup_3.team_lead, target_s2) }

  before do
    # Faculty reviews course that Startup 1 is in.
    faculty.courses << startup_1.level.course

    # Faculty directly reviews Startup 2.
    faculty.startups << startup_2
  end

  describe '#timeline_events' do
    it 'returns timeline events reviewable by faculty' do
      events = subject.timeline_events(School.first)

      # Check if the expected IDs are in the result set. More data is returned, but let's ignore that for simplicity.
      expect(events.map { |e| e[:id] }).to contain_exactly(reviewable_submission_1.id, reviewable_submission_2.id)
    end
  end
end
