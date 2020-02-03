require 'rails_helper'

describe Courses::DemoContentService do
  subject { described_class.new(course) }

  let(:course) { create :course }

  describe '#execute' do
    it 'create all basic resources for a course' do
      subject.execute

      # Create Level 1
      expect(course.levels.count).to eq(1)
      level = course.levels.first
      expect(level.name).to eq("Level 1")
      expect(level.number).to eq(1)

      # Create demo target group in level 1
      expect(level.target_groups.count).to eq(1)
      target_group = level.target_groups.first
      expect(target_group.name).to eq("Demo Target Group")
      expect(target_group.description).to eq("Description of demo target group")
      expect(target_group.milestone).to eq(true)

      # Create a target in the target group
      expect(target_group.targets.count).to eq(1)
      target = target_group.targets.first
      expect(target.role).to eq(Target::ROLE_STUDENT)
      expect(target.title).to eq("Demo Target")
      expect(target.target_action_type).to eq(Target::TYPE_TODO)
      expect(target.visibility).to eq(Target::VISIBILITY_LIVE)

      # Create a markdown content block for the target
      expect(target.current_content_blocks.count).to eq(1)
      expect(target.target_versions.count).to eq(1)
      content_block = target.current_content_blocks.first
      expect(content_block.block_type).to eq(ContentBlock::BLOCK_TYPE_MARKDOWN)
      expect(target.current_content_blocks.first.sort_index).to eq(1)

      # Create 2 evaluation criteria for the course.
      expect(course.evaluation_criteria.count).to eq(2)
      expect(course.evaluation_criteria.first.name).to eq("Correctness of implementation")
      expect(course.evaluation_criteria.last.name).to eq("Quality of submission")
    end
  end
end
