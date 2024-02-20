module Targets
  class UpdateService
    def initialize(target)
      @target = target
    end

    def execute(target_params)
      Target.transaction do
        @target.title = target_params[:title]
        @target.target_action_type = Target::TYPE_TODO

        if target_params[:target_group_id].to_i != @target.target_group_id
          handle_target_group_change(target_params[:target_group_id])
        end

        @target.save!

        update_visibility(target_params[:visibility])

        @target
      end
    end

    private

    def handle_target_group_change(new_target_group_id)
      new_target_group = TargetGroup.find(new_target_group_id)

      @target.sort_index =
        (new_target_group.targets.maximum(:sort_index).to_i + 1)

      @target.target_group = new_target_group
    end

    def update_visibility(visibility)
      ::Targets::UpdateVisibilityService.new(@target, visibility).execute
    end
  end
end
