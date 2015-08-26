class AddProofRequiredToTimelineEventType < ActiveRecord::Migration
  def change
    add_column :timeline_event_types, :proof_required, :string
  end
end
