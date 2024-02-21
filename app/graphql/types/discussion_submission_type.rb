module Types
  class DiscussionSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :target_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :checklist, GraphQL::Types::JSON, null: false
    field :files, [Types::SubmissionFileType], null: false
    field :user_names, String, null: false
    field :users, [Types::UserType], null: false
    field :team_name, String, null: true
    field :comments, [Types::SubmissionCommentType], null: true
    field :reactions, [Types::ReactionType], null: true
    field :anonymous, Boolean, null: false
    field :pinned, Boolean, null: false
    field :moderation_reports, [Types::ModerationReportType], null: false
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
        .batch(default_value: []) do |submission_ids, loader|
          Reaction
            .where(reactionable_type: "TimelineEvent")
            .where(reactionable_id: submission_ids)
            .each do |reaction|
              loader.call(reaction.reactionable_id) do |memo|
                memo |= [reaction].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end

    def comments
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |submission_ids, loader|
          comments =
            SubmissionComment.not_archived.where(submission_id: submission_ids)

          # If moderator, share all comments, else share all current user's comments plus non-hidden comments from other users.
          unless context[:moderator]
            comments =
              comments
                .where(hidden_at: nil)
                .where.not(user: context[:current_user])
                .or(comments.where(user: context[:current_user]))
          end

          comments
            .order(created_at: :desc)
            .limit(100)
            .each do |comment|
              loader.call(comment.submission_id) do |memo|
                memo |= [comment].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end
  end
end
