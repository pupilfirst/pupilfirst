class AddLatestFlagToTimelineEventOwnersTable < ActiveRecord::Migration[6.0]
  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_owners
  end

  class TimelineEventOwner < ApplicationRecord
    belongs_to :timeline_event
  end

  def change
    add_column :timeline_event_owners, :latest, :boolean, default: false

    TimelineEventOwner.reset_column_information

    TimelineEvent.where(latest: true).map do |submission|
      submission.timeline_event_owners.update_all(latest: true)
    end
  end
end
