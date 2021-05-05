class UpdateSubmissionChecklistForFileUploads < ActiveRecord::Migration[6.0]
  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_files
  end

  class TimelineEventFile < ApplicationRecord
    belongs_to :timeline_event, optional: true
  end

  def up
    TimelineEvent.joins(:timeline_event_files).each do |te|
      checklist = te.checklist

      new_checklist = checklist.map { |item| item['kind'] == 'files' ? item.merge('result' => te.timeline_event_files.map(&:id).map(&:to_s)) : item }

      te.update!(checklist: new_checklist)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
