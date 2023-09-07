class AddUserToTimelineEventFile < ActiveRecord::Migration[6.1]
  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_files, dependent: :destroy
    has_many :timeline_event_owners
    has_many :startup_feedback, dependent: :destroy
  end

  class TimelineEventFile < ApplicationRecord
    belongs_to :timeline_event, optional: true
  end

  class TimelineEventOwner < ApplicationRecord
    belongs_to :timeline_event
    belongs_to :student
  end

  class Student < ApplicationRecord
  end

  class StartupFeedback < ApplicationRecord
    belongs_to :timeline_event
  end

  def up
    TimelineEventFile.where(timeline_event_id: nil).each { |file| file.destroy }
    number_of_missing_events =
      TimelineEvent.where.missing(:timeline_event_owners).count
    TimelineEvent
      .where
      .missing(:timeline_event_owners)
      .each_with_index do |event, index|
        puts "Deleting event #{index + 1} of #{number_of_missing_events}"
        event.destroy
      end

    add_reference :timeline_event_files, :user, null: true, foreign_key: true

    TimelineEventFile.reset_column_information

    number_of_files = TimelineEventFile.count
    TimelineEventFile.all.each_with_index do |file, index|
      puts "Updating file #{index + 1} of #{number_of_files}"
      file.update(
        user_id: file.timeline_event.timeline_event_owners.first.student.user_id
      )
    end

    change_column_null :timeline_event_files, :user_id, false
  end
end
