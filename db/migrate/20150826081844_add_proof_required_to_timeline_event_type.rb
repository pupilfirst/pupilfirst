class AddProofRequiredToTimelineEventType < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_event_types, :proof_required, :string
  end
end
