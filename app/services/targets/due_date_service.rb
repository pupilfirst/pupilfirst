module Targets
  class DueDateService
    def initialize(batch)
      @batch = batch
    end

    def expired?(target)
      return true if due_date(target) < Time.now
      false
    end

    def expiring?(target)
      return true if due_date(target) < 8.days.from_now
    end

    # private

    def prepare
      targets = Target.includes(target_group: :program_week).where(program_weeks: { batch_id: @batch.id })
      @due_dates_hash = targets.each_with_object({}) do |target, hash|
        week_number = target.program_week.number
        program_week_start_date = @batch.start_date + ((week_number - 1) * 7).days
        due_date = program_week_start_date + target.days_to_complete.days
        hash[target.id] = due_date
      end
    end

    def due_date(target)
      @due_dates_hash[target.id]
    end
  end
end
