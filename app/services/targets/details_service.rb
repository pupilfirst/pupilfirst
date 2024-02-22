module Targets
  class DetailsService
    include RoutesResolvable

    def initialize(target, student, public_preview:)
      @target = target
      @student = student
      @public_preview = public_preview
    end

    def details
      details = default_props
      if @student.present?
        details =
          details.update(
            {
              pending_user_ids: pending_user_ids,
              submissions: details_for_submissions,
              feedback: feedback_for_submissions,
              grading: grading
            }
          )
      else
        details =
          details.update(
            { pending_user_ids: [], submissions: [], feedback: [], grading: [] }
          )
      end

      if assignment.present?
        details =
          details.update(
            {
              quiz_questions: quiz_questions,
              evaluated: assignment.evaluation_criteria.exists?,
              completion_instructions: assignment.completion_instructions,
              checklist: assignment.checklist,
              comments: comments_for_submissions,
              reactions: reactions_for_submissions,
              discussion: assignment.discussion?,
              allow_anonymous: assignment.allow_anonymous?
            }
          )
      else
        details =
          details.update(
            {
              quiz_questions: [],
              evaluated: false,
              completion_instructions: nil,
              checklist: [],
              comments: [],
              reactions: [],
              discussion: false,
              allow_anonymous: false
            }
          )
      end
      details
    end

    private

    def default_props
      {
        navigation: links_to_adjacent_targets,
        content_blocks: content_blocks,
        communities: community_details
      }
    end

    def links_to_adjacent_targets
      links = {}

      sorted_target_ids =
        @target
          .level
          .target_groups
          .joins(:targets)
          .merge(Target.live)
          .order("target_groups.sort_index", "targets.sort_index")
          .pluck("targets.id")

      target_index = sorted_target_ids.index(@target.id)

      if target_index.present?
        previous_target_id =
          sorted_target_ids[target_index - 1] if target_index.positive?
        next_target_id = sorted_target_ids[target_index + 1]

        links[
          :previous
        ] = "/targets/#{previous_target_id}" if previous_target_id.present?
        links[:next] = "/targets/#{next_target_id}" if next_target_id.present?
      end

      links
    end

    def assignment
      return @assignment if defined?(@assignment)
      @assignment = @target.assignments.not_archived.first
    end

    def communities
      return Community.none if @public_preview

      @target.course.communities.where(target_linkable: true)
    end

    def community_details
      communities.map do |community|
        { id: community.id, name: community.name, topics: topics(community) }
      end
    end

    def topics(community)
      community
        .topics
        .live
        .joins(:target)
        .where(targets: { id: @target })
        .order("last_activity_at DESC NULLs FIRST")
        .first(3)
        .map { |topic| { id: topic.id, title: topic.title } }
    end

    def pending_user_ids
      if @student.team
        @student
          .team
          .students
          .where.not(id: @student)
          .select do |student|
            team_member_submissions =
              student.timeline_events.live.where(target: @target)
            team_member_submissions.failed.count ==
              team_member_submissions.count
          end
          .map(&:user_id)
      else
        []
      end
    end

    def details_for_submissions
      submissions.map do |submission|
        {
          id: submission.id,
          created_at: submission.created_at,
          status: submission.status,
          checklist: submission.checklist,
          hidden_at: submission.hidden_at,
          files: files(submission)
        }
      end
    end

    def submissions
      scope =
        @target
          .timeline_events
          .live
          .joins(:students)
          .where(students: { id: @student })

      if @target.individual_target?
        scope.load
      else
        scope.select do |submission|
          submission.student_ids.sort == @student.team_student_ids
        end
      end
    end

    def user_details(user)
      details = user.attributes.slice("id", "name", "title")
      details["avatar_url"] = user.avatar_url(variant: :thumb)
      details
    end

    def comments_for_submissions
      #TODO - clean up this code using the list of attributes
      reaction_attributes = [
        :id,
        :user_id,
        :reactionable_id,
        :reactionable_type,
        :reaction_value,
        :updated_at,
        "users.name"
      ]
      SubmissionComment
        .includes(:user, :reactions)
        .not_archived
        .where(submission_id: submissions.pluck(:id))
        .order(created_at: :desc)
        .limit(100)
        .map do |comment|
          {
            id: comment.id,
            user_id: comment.user_id,
            user: user_details(comment.user),
            submission_id: comment.submission_id,
            comment: comment.comment,
            reactions:
              comment
                .reactions
                .includes(:user)
                .pluck(*reaction_attributes)
                .map do |id, user_id, reactionable_id, reactionable_type, reaction_value, updated_at, user_name|
                  {
                    id: id,
                    user_id: user_id,
                    reactionable_id: reactionable_id,
                    reactionable_type: reactionable_type,
                    reaction_value: reaction_value,
                    updated_at: updated_at,
                    user_name: user_name
                  }
                end,
            moderation_reports:
              comment.moderation_reports.map do |report|
                report.attributes.transform_values(&:to_s)
              end,
            created_at: comment.created_at,
            hidden_at: comment.hidden_at,
            hidden_by_id: comment.hidden_by_id
          }
        end
    end

    def reactions_for_submissions
      Reaction
        .includes(:user)
        .where(reactionable_type: "TimelineEvent")
        .where(reactionable_id: submissions.pluck(:id))
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
    end

    def feedback_for_submissions
      StartupFeedback
        .where(timeline_event_id: submissions.pluck(:id))
        .map do |feedback|
          {
            id: feedback.id,
            coach_id: feedback.faculty_id,
            submission_id: feedback.timeline_event_id,
            feedback: feedback.feedback
          }
        end
    end

    def files(submission)
      submission.timeline_event_files.with_attached_file.map do |file|
        {
          id: file.id,
          name: file.file.filename,
          url: url_helpers.download_timeline_event_file_path(file)
        }
      end
    end

    def quiz_questions
      return [] if assignment.quiz.blank?

      assignment
        .quiz
        .quiz_questions
        .includes(:answer_options)
        .each_with_index
        .map do |question, index|
          {
            index: index,
            question: question.question,
            description: question.description,
            answer_options: answer_options(question).shuffle
          }
        end
    end

    def answer_options(question)
      question.answer_options.map do |answer|
        answer.attributes.slice("id", "value")
      end
    end

    def content_blocks
      return [] if @target.current_content_blocks.blank?

      @target.current_content_blocks.with_attached_file.map do |content_block|
        cb =
          content_block.attributes.slice(
            "id",
            "block_type",
            "content",
            "sort_index"
          )
        if content_block.file.attached?
          cb["file_url"] = url_helpers.rails_public_blob_url(content_block.file)
          cb["filename"] = content_block.file.filename
        end
        cb
      end
    end

    def grading
      TimelineEventGrade
        .where(timeline_event_id: submissions.pluck(:id))
        .map do |submission_grading|
          {
            submission_id: submission_grading.timeline_event_id,
            evaluation_criterion_id: submission_grading.evaluation_criterion_id,
            grade: submission_grading.grade
          }
        end
    end
  end
end
