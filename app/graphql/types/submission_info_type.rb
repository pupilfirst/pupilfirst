module Types
  class SubmissionInfoType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :archived_at, GraphQL::Types::ISO8601DateTime, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :title, String, null: false
    field :user_names, String, null: false
    field :feedback_sent, Boolean, null: false
    field :team_name, String, null: true
    field :reviewer, Types::ReviewerDetailInfoType, null: true
    field :milestone_number, Int, null: true

    def title
      BatchLoader::GraphQL
        .for(object.target_id)
        .batch do |target_ids, loader|
          Target
            .where(id: target_ids)
            .each { |target| loader.call(target.id, target.title) }
        end
    end

    def milestone_number
      BatchLoader::GraphQL
        .for(object.target_id)
        .batch do |target_ids, loader|
          Target
            .includes(:assignments)
            .where(id: target_ids)
            .each do |target|
              loader.call(target.id, target.assignments.first.milestone_number)
            end
        end
    end

    def user_names
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(students: %i[user])
            .where(id: submission_ids)
            .each do |submission|
              loader.call(
                submission.id,
                submission
                  .students
                  .map { |student| student.user.name }
                  .join(", ")
              )
            end
        end
    end

    def feedback_sent
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(:startup_feedback)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(submission.id, submission.startup_feedback.present?)
            end
        end
    end

    def students_have_same_team?(submission)
      submission.students.distinct(:team_id).pluck(:team_id).count == 1
    end

    def resolve_team_name(submission)
      if submission.timeline_event_owners.size > 1 &&
           submission.team_submission? && students_have_same_team?(submission)
        submission.students.first.team.name
      end
    end

    def team_name
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(:timeline_event_owners, students: %i[team])
            .where(id: submission_ids)
            .each do |submission|
              loader.call(submission.id, resolve_team_name(submission))
            end
        end
    end

    def reviewer
      object.reviewer_id.present? ? object : nil
    end
  end
end
