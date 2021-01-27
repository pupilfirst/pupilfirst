module Targets
  class DetailsService
    include RoutesResolvable

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def details
      if @founder.present?
        {
          pending_user_ids: pending_user_ids,
          submissions: details_for_submissions,
          feedback: feedback_for_submissions,
          grading: grading,
          **default_props
        }
      else
        {
          pending_user_ids: [],
          submissions: [],
          feedback: [],
          grading: [],
          **default_props
        }
      end
    end

    private

    def default_props
      {
        navigation: links_to_adjacent_targets,
        quiz_questions: quiz_questions,
        content_blocks: content_blocks,
        communities: community_details,
        link_to_complete: @target.link_to_complete,
        evaluated: @target.evaluation_criteria.exists?,
        completion_instructions: @target.completion_instructions,
        checklist: @target.checklist
      }
    end

    def links_to_adjacent_targets
      links = {}

      sorted_target_ids = @target.level
        .target_groups
        .joins(:targets)
        .merge(Target.live)
        .order('target_groups.sort_index', 'targets.sort_index')
        .pluck('targets.id')

      target_index = sorted_target_ids.index(@target.id)

      if target_index.present?
        previous_target_id = sorted_target_ids[target_index - 1] if target_index.positive?
        next_target_id = sorted_target_ids[target_index + 1]

        links[:previous] = "/targets/#{previous_target_id}" if previous_target_id.present?
        links[:next] = "/targets/#{next_target_id}" if next_target_id.present?
      end

      links
    end

    def communities
      @target.course.communities.where(target_linkable: true)
    end

    def community_details
      communities.map do |community|
        {
          id: community.id,
          name: community.name,
          topics: topics(community)
        }
      end
    end

    def topics(community)
      community.topics.live.joins(:target).where(targets: { id: @target })
        .order("last_activity_at DESC NULLs FIRST").first(3).map do |topic|
        {
          id: topic.id,
          title: topic.title
        }
      end
    end

    def pending_user_ids
      @founder.startup.founders.where.not(id: @founder).select do |founder|
        team_member_submissions = founder.timeline_events.where(target: @target)
        team_member_submissions.failed.count == team_member_submissions.count
      end.map(&:user_id)
    end

    def details_for_submissions
      submissions.map do |submission|
        {
          id: submission.id,
          created_at: submission.created_at,
          status: submission.status,
          checklist: submission.checklist,
          files: files(submission)
        }
      end
    end

    def submissions
      scope = @target.timeline_events.joins(:founders).where(founders: { id: @founder })

      if @target.individual_target?
        scope.load
      else
        scope.select do |submission|
          submission.founder_ids.sort == @founder.team_student_ids
        end
      end
    end

    def feedback_for_submissions
      StartupFeedback.where(timeline_event_id: submissions.pluck(:id)).map do |feedback|
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
      return [] if @target.quiz.blank?

      @target.quiz.quiz_questions.includes(:answer_options).each_with_index.map do |question, index|
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
        answer.attributes.slice('id', 'value')
      end
    end

    def content_blocks
      return [] if @target.current_content_blocks.blank?

      @target.current_content_blocks.with_attached_file.map do |content_block|
        cb = content_block.attributes.slice('id', 'block_type', 'content', 'sort_index')
        if content_block.file.attached?
          cb['file_url'] = url_helpers.rails_blob_path(content_block.file, only_path: true)
          cb['filename'] = content_block.file.filename
        end
        cb
      end
    end

    def grading
      TimelineEventGrade.where(timeline_event_id: submissions.pluck(:id)).map do |submission_grading|
        {
          submission_id: submission_grading.timeline_event_id,
          evaluation_criterion_id: submission_grading.evaluation_criterion_id,
          grade: submission_grading.grade
        }
      end
    end
  end
end
