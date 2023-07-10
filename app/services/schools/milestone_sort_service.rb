module Schools
  class MilestoneSortService
    def initialize(target, direction)
      @target = target
      @direction = direction
    end

    def execute
      index = milestones.index(target)

      if (index < 1 && should_move_up) ||
           (index >= milestones.size - 1 && !should_move_up)
        return
      end

      target_2 = milestones[should_move_up ? index - 1 : index + 1]

      Target.transaction do
        number = target.milestone_number
        target.update!(milestone_number: target_2.milestone_number)
        target_2.update!(milestone_number: number)
      end
      reassign_milestone_numbers
    end

    private

    def milestones
      @milestones ||=
        target.course.targets.milestones.order(milestone_number: :asc)
    end

    def should_move_up
      @direction == "up"
    end

    def reassign_milestone_numbers
      target
        .course
        .targets
        .milestones
        .order(milestone_number: :asc)
        .each_with_index do |milestone, index|
          unless milestone.milestone_number == index + 1
            milestone.update!(milestone_number: index + 1)
          end
        end
    end

    attr_reader :target
  end
end
