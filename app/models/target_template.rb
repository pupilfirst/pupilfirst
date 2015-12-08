class TargetTemplate < ActiveRecord::Base
  def due_date(batch: Batch.current)
    (batch.start_date + days_from_start).to_date
  end
end
