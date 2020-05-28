class AddLatestFlagToTimelineEventOwnersTable < ActiveRecord::Migration[6.0]
  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_owners
  end

  class TimelineEventOwner < ApplicationRecord
    belongs_to :timeline_event
    belongs_to :founder
  end

  class Founder < ApplicationRecord
    has_many :timeline_event_owners, dependent: :destroy
    has_many :timeline_events, through: :timeline_event_owners
  end

  def change
    add_column :timeline_event_owners, :latest, :boolean, default: false

    TimelineEventOwner.reset_column_information

    Founder.all.includes(:timeline_events).each do |student|
      student.timeline_events.group_by(&:target_id).each do |target_id, submissions|
        TimelineEventOwner.where(founder: student, timeline_event: submissions.sort_by { |s| s.created_at }.last).update(latest: true)
      end
    end
  end
end
