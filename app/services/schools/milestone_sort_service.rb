module Schools
  class MilestoneSortService
    def initialize(target, direction)
      @target = target
      @assignment = @target.assignments.first
      @direction = direction
    end

    def execute
      return unless (target.visibility != Target::VISIBILITY_ARCHIVED && @assignment.milestone)

      milestone_ids = milestones.map(&:id)

      index = milestone_ids.index(target.id.to_i)
      index_2 = index + (move_up? ? -1 : 1)

      return if (index_2 < 0 || index_2 > milestones.size - 1)

      milestone_ids[index], milestone_ids[index_2] =
        milestone_ids[index_2],
        milestone_ids[index]

      Target.transaction do
        milestones.each do |milestone|
          new_index = milestone_ids.index(milestone.id.to_i) + 1
          unless milestone.assignments.first.milestone_number == new_index
            milestone.assignments.first.update!(milestone_number: new_index)
          end
        end
      end
    end

    private

    def milestones
      @milestones ||=
        target.course.targets.live.milestone.order('assignments.milestone_number ASC').to_a
    end

    def move_up?
      @direction == "up"
    end

    attr_reader :target
  end
end
