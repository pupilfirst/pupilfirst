module Courses
  # Creates a clone of a service with a new name.
  #
  # It copies all levels, target groups and targets, but leaves out student infomation and submissions, creating a fresh
  # course ready for modification and use.
  class CloneService
    def initialize(course)
      @course = course
    end

    def clone(new_name)
      Course.transaction do
        Course.create!(name: new_name,
                       description: @course.description,
                       grade_labels: @course.grade_labels,
                       max_grade: @course.max_grade,
                       pass_grade: @course.pass_grade,
                       school: @course.school).tap do |new_course|
          levels = create_levels(new_course)
          target_groups = create_target_groups(levels)
          targets = create_targets(target_groups)
          link_resources(targets)
        end
      end
    end

    def create_levels(new_course)
      @course.levels.map do |level|
        [
          level,
          Level.create!(
            level.attributes
              .slice('name', 'description', 'number')
              .merge(course: new_course)
          )
        ]
      end
    end

    def create_target_groups(levels)
      levels.flat_map do |old_level, new_level|
        old_level.target_groups.where(archived: false).map do |target_group|
          [
            target_group,
            TargetGroup.create!(
              target_group.attributes
                .slice('name', 'description', 'sort_index', 'milestone')
                .merge(level: new_level)
            )
          ]
        end
      end
    end

    def create_targets(target_groups)
      target_groups.flat_map do |old_target_group, new_target_group|
        old_target_group.targets.live.map do |target|
          [
            target,
            Target.create!(
              target.attributes
                .slice(
                  'role', 'title', 'description', 'completion_instructions', 'resource_url', 'slideshow_embed',
                  'faculty_id', 'rubric', 'days_to_complete', 'target_action_type', 'sort_index', 'session_at',
                  'video_embed', 'last_session_at', 'link_to_complete', 'youtube_video_id',
                  'call_to_action'
                )
                .merge(target_group: new_target_group)
            )
          ]
        end
      end
    end

    def link_resources(targets)
      targets.each do |old_target, new_target|
        next if old_target.resources.blank?

        new_target.update!(resources: old_target.resources)
      end
    end
  end
end
