module Types
  class DiscussionSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :target_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :checklist, GraphQL::Types::JSON, null: false
    field :files, [Types::SubmissionFileType], null: false
    field :user_names, String, null: false
    field :users, [UserType], null: false
    field :team_name, String, null: true
    field :comments, [SubmissionCommentType], null: true
    field :reactions, [ReactionType], null: true
    field :anonymous, Boolean, null: false
    field :pinned, Boolean, null: false
    field :moderation_reports, [ModerationReportType], null: false
    field :hidden_at, GraphQL::Types::ISO8601DateTime, null: true

    def files
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(:timeline_event_files)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(
                submission.id,
                submission.timeline_event_files.map do |file|
                  {
                    id: file.id,
                    title: file.file.filename,
                    url:
                      Rails
                        .application
                        .routes
                        .url_helpers
                        .download_timeline_event_file_path(file)
                  }
                end
              )
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
      # object.students.map { |student| student.user.name }.join(', ')
    end

    def users
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(students: :user)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(
                submission.id,
                submission.students.map { |student| student.user }
              )
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

    def reactions
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(:reactions)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(
                submission.id,
                submission
                  .reactions
                  .includes(:user)
                  .map do |reaction|
                    {
                      id: reaction.id,
                      user_id: reaction.user_id,
                      user_name: reaction.user.name,
                      reactionable_id: reaction.reactionable_id,
                      reactionable_type: reaction.reactionable_type,
                      reaction_value: reaction.reaction_value,
                      updated_at: reaction.updated_at
                    }
                  end
              )
            end
        end
    end

    def comments
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |submission_ids, loader|
          TimelineEvent
            .includes(:submission_comments)
            .where(id: submission_ids)
            .each do |submission|
              loader.call(
                submission.id,
                submission
                  .submission_comments
                  .not_archived
                  .includes(:user, :reactions, :moderation_reports)
                  .order(created_at: :desc)
                  .limit(100)
                  .map do |comment|
                    {
                      id: comment.id,
                      user_id: comment.user_id,
                      user: comment.user,
                      submission_id: comment.timeline_event_id,
                      comment: comment.comment,
                      reactions:
                        comment
                          .reactions
                          .includes(:user)
                          .map do |reaction|
                            {
                              id: reaction.id,
                              user_id: reaction.user_id,
                              user_name: reaction.user.name,
                              reactionable_id: reaction.reactionable_id,
                              reactionable_type: reaction.reactionable_type,
                              reaction_value: reaction.reaction_value,
                              updated_at: reaction.updated_at
                            }
                          end,
                      moderation_reports: comment.moderation_reports,
                      created_at: comment.created_at,
                      hidden_at: comment.hidden_at,
                      hidden_by_id: comment.hidden_by_id
                    }
                  end
              )
            end
        end
    end
  end
end
