module Founders
  class DashboardDataService
    def initialize(founder)
      @founder = founder
      @level = @founder.startup.level
    end

    def all_targets
      @all_targets ||= begin
        vanilla_targets = Target.includes(:assigner, :level, :taggings).targets
          .joins(target_group: :level).where('levels.number <= ?', @level.number)
        chores = Target.includes(:assigner, :level, :taggings).chores.upto_level(@level)
        sessions = Target.includes(:assigner, :level, :taggings).sessions.upto_level(@level)

        vanilla_targets + chores + sessions
      end
    end

    def vanilla_targets
      all_targets.select(&:target_group_id?)
    end

    def new_chores
      all_targets.select(&:chore?)
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
    end

    def new_sessions
      all_targets.select(&:session_at?)
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
            level: { only: [:number] },
            taggings: taggings_fields
          }
        )
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
      target = Target.find(target_data['id'])

      # Add status of target to compiled data.
      target_data['status'] = target.status(@founder).to_s

      # Add time of submission of last event, necessary for submitted and completed state.
      if target_data['status'].in?([Targets::StatusService::STATUS_SUBMITTED.to_s, Targets::StatusService::STATUS_COMPLETE.to_s])
        timeline_events = target.founder_role? ? @founder.timeline_events : @founder.startup.timeline_events
        target_data['submitted_at'] = timeline_events.where(target: target).last.created_at.iso8601
      end

      target_data
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
