class FixLatestFlagForIndividualTargetSubmissions < ActiveRecord::Migration[6.0]
  class TimelineEvent < ApplicationRecord
    has_many :timeline_event_owners
    belongs_to :target
    has_many :target_evaluation_criteria, through: :target
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
    ROLE_TEAM = 'team'

    has_many :target_evaluation_criteria

    def team_target?
      role == ROLE_TEAM
    end
  end

  class TargetEvaluationCriterion < ApplicationRecord
  end

  def up
    Founder.joins(timeline_events: { target: :target_evaluation_criteria }).distinct.find_each do |student|
      student.timeline_events.joins(target: :target_evaluation_criteria).distinct.group_by(&:target_id).each do |_target_id, submissions|
        latest_submission = submissions.sort_by { |s| s.created_at }.last

        next if latest_submission.target.team_target?

        TimelineEventOwner.where(founder_id: student.id, timeline_event_id: latest_submission.id).update_all(latest: true)
      end
    end
  end


  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
