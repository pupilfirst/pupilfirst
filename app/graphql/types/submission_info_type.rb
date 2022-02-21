module Types
  class SubmissionInfoType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :archived_at, GraphQL::Types::ISO8601DateTime, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :title, String, null: false
    field :level_number, Int, null: false
    field :user_names, String, null: false
    field :feedback_sent, Boolean, null: false
    field :team_name, String, null: true
    field :reviewer, Types::ReviewerDetailInfoType, null: true

    def title
      BatchLoader::GraphQL
        .for(object.target_id)
        .batch do |target_ids, loader|
          Target
            .where(id: target_ids)
            .each { |target| loader.call(target.id, target.title) }
        end
      # object.target.title
    end

    def level_number
      BatchLoader::GraphQL
        .for(object.target_id)
        .batch do |target_ids, loader|
          Target
            .includes(target_group: :level)
            .where(id: target_ids)
            .each do |target|
              loader.call(target.id, target.target_group.level.number)
            end
        end
      # object.target.target_group.level.number
    end

    def user_names
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(founders: %i[user])
            .where(id: submission_ids)
            .each do |submission|
              loader.call(
                submission.id,
                submission
                  .founders
                  .map { |founder| founder.user.name }
                  .join(', ')
              )
            end
        end
      # object.founders.map { |founder| founder.user.name }.join(', ')
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
      # object.startup_feedback.present?
    end

    def students_have_same_team(submission)
      submission.founders.distinct(:startup_id).pluck(:startup_id).one?
    end

    def resolve_team_name(submission)
      if submission.team_submission? && students_have_same_team(submission) &&
           submission.timeline_event_owners.count > 1
        submission.founders.first.startup.name
      end
    end

    def team_name
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(:timeline_event_owners, :target, founders: %i[startup])
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
