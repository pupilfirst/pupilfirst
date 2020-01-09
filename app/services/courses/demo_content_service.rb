module Courses
  class DemoContentService
    def initialize(course)
      @course = course
    end

    def execute
      Course.transaction do
        level_one = create_level_one
        new_target_group = create_target_group(level_one)
        create_target(new_target_group)
        create_evaluation_criterion("Correctness of implementation")
        create_evaluation_criterion("Quality of submission")
      end
    end

    private

    def create_level_one
      Level.create!(
        name: 'Level 1',
        number: 1,
        course: @course
      )
    end

    def create_target_group(level)
      TargetGroup.create!(
        name: "Demo Target Group",
        description: "Description of demo target group",
        sort_index: 1,
        milestone: true,
        level: level
      )
    end

    def create_target(target_group)
      target = Target.create!(
        role: Target::ROLE_STUDENT,
        title: "Demo Target",
        target_action_type: Target::TYPE_TODO,
        target_group: target_group,
        sort_index: 1,
        visibility: Target::VISIBILITY_LIVE
      )
      ContentBlocks::DemoMarkdownBlockService.new(target).execute
    end

    def create_evaluation_criterion(name)
      EvaluationCriterion.create!(
        name: name,
        course: @course,
        max_grade: 3,
        pass_grade: 2,
        grade_labels: [{ 'grade' => 1, 'label' => 'Bad' }, { 'grade' => 2, 'label' => 'Good' }, { 'grade' => 3, 'label' => 'Great' }]
      )
    end
  end
end
