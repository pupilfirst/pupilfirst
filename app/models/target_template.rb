class TargetTemplate < ActiveRecord::Base
  def due_date(batch: current_batch)
    (batch.start_date + days_from_start).to_date
  end

  # TODO: Rewrite this once batch is a model.
  def current_batch
    OpenStruct.new(
      start_date: Date.parse('2015-08-17')
    )
  end
end
