class RemoveTimelineEventsWithMissingTarget < ActiveRecord::Migration[6.1]
  class TimelineEvent < ApplicationRecord
    belongs_to :target
  end

  class Target < ApplicationRecord
    has_many :timeline_events, dependent: :restrict_with_error
  end

  def up
    te_missing_targets = TimelineEvent.where.missing(:target)
    puts "Destroying #{te_missing_targets.count} timeline events with missing targets"
    te_missing_targets.destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
