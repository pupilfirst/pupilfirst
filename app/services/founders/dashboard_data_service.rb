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

    def chores
      applicable_levels = startup.level.number.zero? ? 0 : (1..startup.level.number).to_a

      @chores ||= begin
        targets = Target.includes(:assigner, :level)
          .where(chore: true)
          .where(levels: { number: applicable_levels })
          .order(:sort_index)
          .as_json(
            only: target_fields,
            methods: %i(has_rubric target_type_description),
            include: {
              assigner: { only: assigner_fields },
              level: { only: [:number] }
            }
          )

        targets_with_status(targets)
      end
    end

    def sessions
      applicable_levels = startup.level.number.zero? ? 0 : [1, 2, 3, 4]

      @sessions ||= begin
        targets = Target.includes(:assigner, :level, :taggings).where.not(session_at: nil)
          .where(levels: { number: applicable_levels }).order(session_at: :desc)
          .as_json(
            only: target_fields,
            methods: %i(has_rubric target_type_description),
            include: {
              assigner: { only: assigner_fields },
              level: { only: [:number] },
              taggings: {
                only: [],
                include: {
                  tag: { only: [:name] }
                }
              }
            }
          )

        targets_with_status(targets)
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
              methods: %i(has_rubric target_type_description),
              include: {
                assigner: {
                  only: %i(id name)
                }
              }
            }
          }
        )

      groups_with_target_status(groups)
    end

    def targets_with_status(targets)
      targets.map do |target_data|
        target_data_with_status(target_data)
      end
    end

    def groups_with_target_status(groups)
      groups.map do |group|
        group['targets'] = group['targets'].map do |target_data|
          target_data_with_status(target_data)
        end

        group
      end
    end

    def target_data_with_status(target_data)
      # Add status of target to compiled data.
      target_data['status'] = target_statuses.find { |e| e[0] == target_data['id'] }&.second || Targets::BulkStatusService::STATUS_PENDING
      # Add time of submission of last event, necessary for submitted and completed state.
      if target_data['status'].in?([Targets::BulkStatusService::STATUS_SUBMITTED, Targets::BulkStatusService::STATUS_COMPLETE])
        target_data['submitted_at'] = target_statuses.find { |e| e[0] == target_data['id'] }&.third
      end

      target_data
    end

    def target_statuses
      @target_statuses ||= Targets::BulkStatusService.new(@founder).statuses
    end

    def startup
      @startup ||= @founder.startup
    end

    def target_group_fields
      %i(id name description milestone)
    end

    def target_fields
      %i(id role title description completion_instructions resource_url slideshow_embed video_embed days_to_complete points_earnable timeline_event_type_id session_at link_to_complete submittability)
    end

    def assigner_fields
      %i(id name)
    end

    def taggings_fields
      {
        only: [],
        include: {
          tag: { only: [:name] }
        }
      }
    end
  end
end
