module Founders
  class DashboardDataService
    def initialize(founder)
      @founder = founder
      @level = @founder.startup.level
    end

    def all_targets
      @all_targets ||= begin
        targets = Target.includes(:assigner, :level, :taggings)
        vanilla_targets = filter_for_level(targets.targets.joins(target_group: :level))
        chores = filter_for_level(targets.chores.joins(:level))
        sessions = filter_for_level(targets.sessions.joins(:level))

        vanilla_targets + chores + sessions
      end
    end

    def vanilla_targets
      all_targets.select(&:target_group_id?)
    end

    def chores
      @chores ||= begin
        chores = all_targets.select(&:chore?)
          .sort do |a, b|
            if a.sort_index && b.sort_index
              a.sort_index <=> b.sort_index
            else
              a.sort_index ? -1 : 1
            end
          end
          .as_json(
            only: target_fields,
            methods: %i(has_rubric target_type_description),
            include: {
              assigner: { only: assigner_fields },
              level: { only: [:number] }
            }
          )
        targets_with_status(chores)
      end
    end

    def sessions
      @sessions ||= begin
        sessions = all_targets.select(&:session_at?)
          .sort_by { |session| session['session_at'] }.reverse
          .as_json(
            only: target_fields,
            methods: %i(has_rubric target_type_description),
            include: {
              assigner: { only: assigner_fields },
              level: { only: [:number] },
              taggings: taggings_fields
            }
          )
        targets_with_status(sessions)
      end
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

    def session_tags
      @session_tags ||= Target.tag_counts_on(:tags).pluck(:name)
    end

    private

    def filter_for_level(targets)
      @level == Level.zero ? targets.where(level: @level) : targets.where('levels.number BETWEEN ? AND ?', 1, @level.number)
    end

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
