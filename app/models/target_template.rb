class TargetTemplate < ActiveRecord::Base
  belongs_to :assigner, class_name: 'Faculty'

  # ensure required fields for a target (which cannot be auto-alloted) are specified
  validates_presence_of :role, :title, :description

  validates_presence_of :assigner_id, if: :populate_on_start?

  def due_date(batch: Batch.current)
    (batch.start_date + days_from_start).to_date
  end
end
