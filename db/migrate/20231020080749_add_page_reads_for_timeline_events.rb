class AddPageReadsForTimelineEvents < ActiveRecord::Migration[6.1]

  class TimelineEventOwner < ApplicationRecord
    belongs_to :timeline_event
    belongs_to :student
  end

  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_owners
  end

  def up
    TimelineEventOwner.includes(:timeline_event).find_in_batches do |timeline_event_owners|
      page_reads_array = []
      timeline_event_owners.each do |timeline_event_owner|
        page_read_hash = {:target_id => timeline_event_owner.timeline_event.target_id, :student_id => timeline_event_owner.student_id, :created_at => timeline_event_owner.timeline_event.created_at}
        page_reads_array.append(page_read_hash)
      end
      PageRead.insert_all(page_reads_array)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
