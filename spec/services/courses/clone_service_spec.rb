require 'rails_helper'

describe Courses::CloneService do
  include FounderSpecHelper

  subject { described_class.new(course) }

  let(:course) { create :course, sponsored: true }
  let(:level_one) { create :level, :one, course: course }
  let(:level_two) { create :level, :two, course: course }
  let(:target_group_l1_1) { create :target_group, level: level_one, milestone: true }
  let(:target_group_l1_2) { create :target_group, level: level_one }
  let(:target_group_l2) { create :target_group, level: level_two, milestone: true }
  let(:target_l1_1_1) { create :target, :for_startup, target_group: target_group_l1_1 }
  let(:target_l1_1_2) { create :target, :for_startup, target_group: target_group_l1_1 }
  let(:target_l1_2) { create :target, :for_startup, target_group: target_group_l1_2 }
  let(:target_l2_1) { create :target, :for_founders, target_group: target_group_l2 }
  let!(:target_l2_2) { create :target, :for_founders, target_group: target_group_l2 }
  let(:startup_l1) { create :startup, level: level_one }
  let(:startup_l2) { create :startup, level: level_two }
  let!(:resource_1) { create :resource_link, targets: [target_l1_1_1] }
  let!(:resource_2) { create :resource_video_embed, targets: [target_l1_1_2] }
  let!(:resource_3) { create :resource_video_file, targets: [target_l2_1] }

  let(:new_name) { Faker::Lorem.words(2).join(' ') }

  before do
    complete_target(startup_l1.team_lead, target_l1_1_1)
    complete_target(startup_l2.team_lead, target_l1_1_1)
    complete_target(startup_l2.team_lead, target_l1_1_2)
    complete_target(startup_l2.team_lead, target_l1_2)
    complete_target(startup_l2.team_lead, target_l2_1)
  end

  describe '#clone' do
    it 'create a clone of the course with the supplied name' do
      original_level_names = Level.all.pluck(:name)
      original_group_names = TargetGroup.all.pluck(:name)
      original_targets = Target.all.pluck(:title, :description)
      original_startup_count = Startup.count
      original_founder_count = Founder.count
      original_submission_count = TimelineEvent.count

      new_course = subject.clone(new_name, true)

      # New course should have same name as the old one.
      expect(new_course.name).to eq(new_name)
      expect(new_course.sponsored).to eq(true)

      # Levels, target groups, targets, and resources should have been cloned.
      expect(new_course.levels.pluck(:name)).to match_array(original_level_names)
      expect(new_course.target_groups.pluck(:name)).to match_array(original_group_names)
      expect(new_course.targets.pluck(:title, :description)).to match_array(original_targets)

      # Resources should have been linked to new targets.
      expect(Resource.count).to eq(3)
      expect(new_course.targets.joins(:resources).count).to eq(3)

      # There should be no cloning of startups, founders, or timeline events.
      expect(Startup.count).to eq(original_startup_count)
      expect(Founder.count).to eq(original_founder_count)
      expect(TimelineEvent.count).to eq(original_submission_count)
    end
  end
end
