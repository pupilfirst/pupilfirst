module Schools
  class MilestoneSwapService
    def initialize(milestones, target, direction)
      @milestones = milestones
      @target = target
      @should_move_up = direction == "up"
    end

    def execute
      index = @milestones.index(@target)

      if (index < 1 && @should_move_up) ||
           (index >= @milestones.size - 1 && !@should_move_up)
        return
      end

      target_2 = @milestones[@should_move_up ? index - 1 : index + 1]

      Target.transaction do
        number = @target.milestone_number
        @target.update!(milestone_number: target_2.milestone_number)
        target_2.update!(milestone_number: number)
      end
    end
  end
end
