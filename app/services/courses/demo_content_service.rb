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

        create_evaluation_criterion(
          I18n.t("services.courses.demo_content_service.criterion_one")
        )

        create_evaluation_criterion(
          I18n.t("services.courses.demo_content_service.criterion_two")
        )
      end
    end

    private

    def create_level_one
      Level.create!(
        name: I18n.t("services.courses.demo_content_service.level_1"),
        number: 1,
        course: @course
      )
    end

    def create_target_group(level)
      TargetGroup.create!(
        name: I18n.t("services.courses.demo_content_service.target_group_name"),
        description:
          I18n.t(
            "services.courses.demo_content_service.target_group_description"
          ),
        sort_index: 1,
        level: level
      )
    end

    def create_target(target_group)
      target =
        Target.create!(
          title: I18n.t("services.courses.demo_content_service.target_name"),
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
        grade_labels: [
          {
            "grade" => 1,
            "label" => I18n.t("services.courses.demo_content_service.grade_1")
          },
          {
            "grade" => 2,
            "label" => I18n.t("services.courses.demo_content_service.grade_2")
          },
          {
            "grade" => 3,
            "label" => I18n.t("services.courses.demo_content_service.grade_3")
          }
        ]
      )
    end
  end
end
