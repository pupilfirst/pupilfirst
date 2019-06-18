module Targets
  class DetailsService
    include RoutesResolvable

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def details
      {
        pending_student_ids: pending_founder_ids,
        submissions: details_for_submissions,
        submission_attachments: attachments_for_submissions,
        feedback: feedback_for_submissions,
        quiz_questions: quiz_questions,
        content_blocks: content_blocks,
        communities: community_details,
        link_to_complete: @target.link_to_complete,
        evaluated: @target.evaluation_criteria.exists?,
        grading: grading
      }
    end

    private

    def communities
      @target.course.communities.where(target_linkable: true)
    end

    def community_details
      communities.map do |community|
        {
          id: community.id,
          name: community.name,
          questions: questions(community)
        }
      end
    end

    def questions(community)
      community.questions.joins(:targets).where(targets: { id: @target })
        .order("last_activity_at DESC NULLs FIRST").first(3).map do |question|
        {
          id: question.id,
          title: question.title
        }
      end
    end

    def pending_founder_ids
      return [] unless @target.founder_role?

      @founder.startup.founders.where.not(id: @founder).reject do |founder|
        founder.exited? || founder.timeline_events.where(target: @target).passed.exists?
      end.map(&:id)
    end

    def details_for_submissions
      submissions.map do |submission|
        {
          id: submission.id,
          description: submission.description,
          created_at: submission.created_at,
          status: submission.status
        }
      end
    end

    def submissions
      @target.timeline_events.joins(:founders).where(founders: { id: @founder }).load
    end

    def feedback_for_submissions
      StartupFeedback.where(timeline_event_id: submissions.pluck(:id)).as_json(only: %i[faculty_id feedback])
    end

    def attachments_for_submissions
      submissions.map do |submission|
        files = submission.timeline_event_files.with_attached_file.map do |file|
          {
            id: file.id,
            submission_id: submission.id,
            submission_type: "file",
            title: file.file.filename,
            url: url_helpers.download_timeline_event_file_path(file)
          }
        end

        links = submission.links.map do |link|
          {
            submission_id: submission.id,
            submission_type: "link",
            url: link
          }
        end

        files + links
      end.flatten
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
        answer.attributes.slice('id', 'value', 'hint')
      end
    end

    def content_blocks
      @target.content_blocks.with_attached_file.map do |content_block|
        cb = content_block.attributes.slice('id', 'block_type', 'content', 'sort_index')
        if content_block.file.attached?
          cb['file_url'] = url_helpers.url_for(content_block.file)
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
