module Founders
  class DashboardDataService
    def initialize(founder)
      @founder = founder
    end

    def levels
      @levels ||= (1..startup.level.number).each_with_object({}) do |level_number, levels|
        level = Level.find_by(number: level_number)

        levels[level_number] = {
          name: level.name,
          target_groups: target_groups(level)
        }
      end
    end

    def chores
      @chores ||= begin
        targets = Target.includes(:assigner, :level).where(chore: true)
          .order(:sort_index)
          .decorate
          .as_json(
            only: target_fields,
            include: {
              assigner: { only: assigner_fields },
              level: { only: [:number] }
            }
          )

        targets_with_status(targets)
      end
    end

    def sessions
      @sessions ||= begin
        targets = Target.where.not(session_at: nil)
          .order(:sort_index)
          .decorate
          .as_json(
            only: target_fields,
            include: {
              assigner: { only: assigner_fields }
            }
          )

        targets_with_status(targets)
      end
    end

    private

    def target_groups(level)
      groups = level.target_groups.includes(targets: :assigner)
        .order('target_groups.sort_index', 'targets.sort_index')
        .decorate
        .as_json(
          only: target_group_fields,
          include: {
            targets: {
              only: target_fields,
              include: {
                assigner: {
                  only: [:id, :name]
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
      if target_data['status'].in?([Targets::StatusService::STATUS_SUBMITTED, Targets::StatusService::STATUS_COMPLETE])
        target_data['submitted_at'] = target.timeline_events.last.created_at.iso8601
      end

      target_data
    end

    def startup
      @startup ||= @founder.startup
    end

    def target_group_fields
      [:id, :name, :description, :milestone]
    end

    def target_fields
      [
        :id, :role, :title, :description, :completion_instructions, :resource_url, :slideshow_embed, :video_embed,
        :days_to_complete, :points_earnable, :timeline_event_type_id
      ]
    end

    def assigner_fields
      [:id, :name]
    end
  end
end
