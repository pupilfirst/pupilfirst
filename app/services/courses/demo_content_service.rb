module Courses
  class DemoContentService
    def initialize(course)
      @course = course
    end

    def execute
      new_level = create_level
      new_target_group = create_target_group(new_level)
      create_target(new_target_group)
      evaluation_criterion("Correctness of implementation")
      evaluation_criterion("Quality of research")
      evaluation_criterion("Understanding of subject matter")
    end

    private

    def create_level
      Level.create!(
        name: 'Level 1',
        number: 1,
        course: @course
      )
    end

    def create_target_group(level)
      TargetGroup.create!(
        name: "Demo Target Group",
        description: "Demo Target Group Description",
        sort_index: 1,
        milestone: true,
        level: level
      )
    end

    def create_target(target_group)
      Target.create!(
        role: "founder",
        title: "Demo Target",
        description: "Demo Target Description",
        completion_instructions: "Click on Mark As Complete",
        target_action_type: "Todo",
        target_group: target_group,
        sort_index: 1
      )
    end

    def evaluation_criterion(name)
      EvaluationCriterion.create!(
        description: name,
        name: name,
        course: @course
      )
    end
  end
end
