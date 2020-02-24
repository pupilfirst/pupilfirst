class AddChecklistResponseToTimelineEvents < ActiveRecord::Migration[6.0]
  class TimelineEventFile < ActiveRecord::Base
    has_one :timeline_event
  end

  class EvaluationCriterion < ApplicationRecord
    has_many :target_evaluation_criteria, dependent: :restrict_with_error
    has_many :targets, through: :target_evaluation_criteria
  end

  class TargetEvaluationCriterion < ApplicationRecord
    belongs_to :target
    belongs_to :evaluation_criterion
  end

  class TimelineEvent < ActiveRecord::Base
    belongs_to :target
    has_many :target_evaluation_criteria, through: :target
    has_many :evaluation_criteria, through: :target_evaluation_criteria
    has_many :timeline_event_files, dependent: :destroy

    serialize :links
  end

  def up
    add_column :timeline_events, :checklist, :jsonb, default: []

    TimelineEvent.reset_column_information

    TimelineEvent.all.each do |submission|
      if submission.evaluation_criteria.present?
        submission.update!(checklist: submission_checklist(submission))
      elsif submission.score.present?
        submission.update!(checklist: quiz_checklist(submission))
      end
    end
  end

  def down
    remove_column :timeline_events, :checklist
  end


  def quiz_checklist(submission)
    description = {
      title: "Quiz",
      result: submission.description,
      kind: "longText",
      status: "noAnswer"
    }
    [description]
  end

  def submission_checklist(submission)
    description = {
      title: "Description",
      result: submission.description,
      kind: "longText",
      status: "noAnswer"
    }

    links = submission.links.map do |link|
      {
        title: "Link",
        result: link,
        kind: "link",
        status: "noAnswer"
      }
    end

    file = {
      title: "File",
      result: "",
      kind: "files",
      status: "noAnswer"
    }

    checklist = [description] + links + (submission.timeline_event_files.any? ? [file] : [])
    checklist
  end
end
