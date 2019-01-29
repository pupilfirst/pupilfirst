module Founders
  class DashboardDataService
    def initialize(founder)
      @founder = founder
    end

    def props
      {
        targets: targets,
        levels: levels_as_json,
        faculty: faculty,
        targetGroups: target_groups,
        tracks: tracks,
        criteriaNames: criteria_names,
        gradeLabels: course.grade_labels
      }
    end

    private

    def targets
      applicable_targets = Target.live.joins(target_group: :level).where(target_groups: { level: open_levels }).includes(:faculty)

      # Load basic data about targets from database.
      loaded_targets = applicable_targets.as_json(
        only: target_fields,
        include: {
          target_group: { only: :id },
          faculty: { only: :id }
        }
      )

      # Add additional data that cannot be directly queried to each target.
      loaded_targets.map do |target|
        dashboard_decorated_data(target)
      end
    end

    def visible_levels
      @visible_levels ||= course.levels.where('levels.number >= ?', 1)
    end

    def open_levels
      @open_levels ||= visible_levels.where(unlock_on: nil).or(visible_levels.where('unlock_on <= ?', Date.today))
    end

    def levels_as_json
      visible_levels.as_json(
        only: %i[id name number],
        methods: :unlocked
      )
    end

    def faculty
      Faculty.team.all.as_json(
        only: %i[id name],
        methods: :image_or_avatar_url
      )
    end

    def target_groups
      TargetGroup.joins(:level).where(level: open_levels, archived: false)
        .as_json(
          only: %i[id name description milestone sort_index],
          include: { track: { only: :id }, level: { only: :id } }
        )
    end

    def tracks
      Track.all.as_json(only: %i[id name sort_index])
    end

    def criteria_names
      course.evaluation_criteria.each_with_object({}) do |criterion, result|
        result[criterion.id] = criterion.name
      end
    end

    def dashboard_decorated_data(target_data)
      target_id = target_data['id']
      target_data['status'] = target_status_service.status(target_id)
      target_data['submitted_at'] = target_status_service.submitted_at(target_id)
      target_data['grades'] = target_status_service.grades(target_id)
      target_data['prerequisites'] = target_status_service.prerequisite_targets(target_id).as_json(only: [:id])
      target_data['auto_verified'] = !target_id.in?(targets_with_criteria)
      target_data['has_quiz'] = Target.find_by(id: target_data['id']).quiz?
      target_data
    end

    def target_has_quiz(id)
      Target.find_by(id: id).quiz?
    end

    def target_status_service
      @target_status_service ||= Founders::TargetStatusService.new(@founder)
    end

    def startup
      @startup ||= @founder.startup
    end

    def course
      @course ||= startup.course
    end

    def target_fields
      %i[id role title description completion_instructions resource_url slideshow_embed video_embed youtube_video_id days_to_complete points_earnable resubmittable session_at link_to_complete call_to_action sort_index]
    end

    def targets_with_criteria
      @targets_with_criteria ||= Target.joins(:target_evaluation_criteria).pluck(:id)
    end
  end
end
