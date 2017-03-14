module Founders
  class DashboardDataService
    def initialize(founder)
      @founder = founder
    end

    def target_groups
      @target_groups ||= startup.level.target_groups.includes(targets: :assigner)
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
    end

    def chores
      @chores ||= Target.includes(:assigner).where(chore: true)
        .order(:sort_index)
        .decorate
        .as_json(
          only: target_fields,
          include: {
            assigner: { only: assigner_fields }
          }
        )
    end

    def sessions
      @sessions ||= Target.where.not(session_at: nil)
        .order(:sort_index)
        .decorate
        .as_json(
          only: target_fields,
          include: {
            assigner: { only: assigner_fields }
          }
        )
    end

    private

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
