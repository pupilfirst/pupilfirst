module Founders
  class DashboardDataService
    def initialize(founder)
      @founder = founder
    end

    def levels
      start_level = startup.level.number.zero? ? 0 : 1

      @levels ||= (start_level..startup.level.number).each_with_object({}) do |level_number, levels|
        level = Level.find_by(number: level_number)

        levels[level_number] = {
          name: level.name,
          target_groups: target_groups(level)
        }
      end
    end

    def sessions
      applicable_levels = startup.level.number.zero? ? 0 : (1..startup.maximum_level.number).to_a

      @sessions ||= begin
        targets = Target.includes(:assigner, :level, :taggings)
          .where.not(session_at: nil).where(archived: false)
          .where(levels: { number: applicable_levels }).order(session_at: :desc)
          .as_json(
            only: target_fields,
            methods: %i[has_rubric target_type target_type_description],
            include: {
              assigner: assigner_fields,
              level: { only: [:number] },
              taggings: taggings_field
            }
          )

        dashboard_decorate(targets)
      end
    end

    def session_tags
      @session_tags ||= Target.tag_counts_on(:tags).pluck(:name)
    end

    private

    def target_groups(level)
      groups = level.target_groups.includes(targets: :assigner)
        .order('target_groups.sort_index', 'targets.sort_index')
        .as_json(
          only: target_group_fields,
          include: {
            targets: {
              only: target_fields,
              methods: %i[has_rubric target_type target_type_description],
              include: {
                assigner: assigner_fields
              }
            }
          }
        )

      trim_archived_targets(groups)

      dashboard_decorate_groups(groups)
    end

    def dashboard_decorate(targets)
      targets.map do |target_data|
        dashboard_decorated_data(target_data)
      end
    end

    def dashboard_decorate_groups(groups)
      groups.map do |group|
        group['targets'] = group['targets'].map do |target_data|
          dashboard_decorated_data(target_data)
        end

        group
      end
    end

    def dashboard_decorated_data(target_data)
      # Add status of target to compiled data.
      target_data['status'] = target_status_service.status(target_data['id'])

      # Add time of submission of last event, necessary for submitted and completed state.
      if target_data['status'].in?([Target::STATUS_SUBMITTED, Target::STATUS_COMPLETE])
        target_data['submitted_at'] = target_status_service.submitted_at(target_data['id'])
      end

      # add grade if completed
      target_data['grade'] = target_grade_service.grade(target_data['id']) if target_data['status'] == Target::STATUS_COMPLETE

      # add array of prerequisites
      target_data['prerequisites'] = target_status_service.prerequisite_targets(target_data['id'])

      target_data
    end

    def trim_archived_targets(groups)
      groups.map do |group|
        group['targets'].reject! { |target| target['archived'] }
        group
      end
    end

    def target_status_service
      @target_status_service ||= Founders::TargetStatusService.new(@founder)
    end

    def target_grade_service
      @target_grade_service ||= Founders::TargetGradeService.new(@founder)
    end

    def startup
      @startup ||= @founder.startup
    end

    def target_group_fields
      %i[id name description milestone]
    end

    def target_fields
      %i[id role title description completion_instructions resource_url slideshow_embed video_embed days_to_complete points_earnable timeline_event_type_id session_at link_to_complete submittability archived]
    end

    def assigner_fields
      {
        only: %i[id name],
        methods: :image_url
      }
    end

    def taggings_field
      {
        only: [],
        include: {
          tag: { only: [:name] }
        }
      }
    end
  end
end
