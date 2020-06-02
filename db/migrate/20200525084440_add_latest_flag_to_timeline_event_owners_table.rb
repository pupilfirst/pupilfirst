class AddLatestFlagToTimelineEventOwnersTable < ActiveRecord::Migration[6.0]
  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_owners
    belongs_to :target
    has_many :target_evaluation_criteria, through: :target

    scope :not_auto_verified, -> { joins(:target_evaluation_criteria).distinct }
    scope :auto_verified, -> { where.not(id: not_auto_verified) }
  end

  class TimelineEventOwner < ApplicationRecord
    belongs_to :timeline_event
    belongs_to :founder
  end

  class Founder < ApplicationRecord
    has_many :timeline_event_owners
    has_many :timeline_events, through: :timeline_event_owners
  end

  class Target < ApplicationRecord
    has_many :target_evaluation_criteria
  end

  class TargetEvaluationCriterion < ApplicationRecord
  end

  def up
    add_column :timeline_event_owners, :latest, :boolean, default: false

    TimelineEventOwner.reset_column_information

    Founder.joins(timeline_events: { target: :target_evaluation_criteria }).distinct.find_each do |student|
      student.timeline_events.joins(target: :target_evaluation_criteria).distinct.group_by(&:target_id).each do |target_id, submissions|
        latest_submission = submissions.sort_by { |s| s.created_at }.last
        TimelineEventOwner.where(founder_id: student.id, timeline_event_id: latest_submission.id).update_all(latest: true)
      end
    end

    TimelineEventOwner.where(timeline_event: TimelineEvent.auto_verified).update_all(latest: true)
  end


  def down
    remove_column :timeline_event_owners, :latest, :boolean
  end
end
