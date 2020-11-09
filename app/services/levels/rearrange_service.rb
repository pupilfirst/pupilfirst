module Levels
  class RearrangeService
    def initialize(level)
      @level = level
    end

    # Take the place of another level.
    def move_to(target_level)
      raise 'Cannot move level between courses' if @level.course != target_level.course

      return if target_level.number == @level.number

      Level.transaction do
        case target_level.number
          when 0
            raise 'Level 0 already exists - cannot proceed' if levels.exists?(number: 0)
            raise 'No other level exists - cannot proceed' if levels.count == 1

            displace_level
            move_down_levels_above(0)
            @level.update!(number: 0)
          when max_level_number
            # In this case, we need to shift everything above the selected level down by one, and then move selected level
            # to the end.

            original_level_number = @level.number
            displace_level
            move_down_levels_above(original_level_number)
          else
            if @level.number > target_level.number
              displace_level
              target_level_number = target_level.number
              move_up_levels((target_level.number..(@level.number - 1)))
              @level.update(number: target_level_number)
            else
              # Move down levels.
            end
        end
      end
    end

    private

    def move_up_levels(range)
      course.levels.where(number: range).order(number: :desc).each do |level|
        level.update!(number: level.number + 1)
      end
    end


    def displace_level
      @level.update!(number: max_level_number + 1)
    end

    def move_down_levels_above(level_number)
      levels.where('number > ?', level_number).each do |higher_level|
        higher_level.update!(number: higher_level.number - 1)
      end
    end

    def max_level_number
      @max_level_number ||= levels.order(number: :desc).pick(:number)
    end

    def levels
      course.levels
    end

    def course
      @course ||= @level.course
    end
  end
end
