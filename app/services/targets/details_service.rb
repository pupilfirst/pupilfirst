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
        latest_submission_details: latest_event_details,
        latest_submission_attachments: latest_event_attachments,
        latest_feedback: latest_feedback_details,
        quiz_questions: quiz_questions,
        content_blocks: content_blocks,
        communities: community_details
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

    def latest_event_details
      return nil if latest_event.blank?

      latest_event.attributes.slice('id', 'description', 'created_at')
    end

    def latest_event
      @latest_event ||= @target.timeline_events.joins(:founders).where(founders: { id: @founder }).find_by(latest: true)
    end

    def latest_feedback_details
      return if latest_feedback.blank?

      latest_feedback.attributes.slice('faculty_id', 'feedback')
    end

    def latest_feedback
      @latest_feedback ||= latest_event&.startup_feedback&.order('created_at')&.last
    end

    def latest_event_attachments
      return [] if latest_event.blank?

      files = latest_event.timeline_event_files.map do |file|
        {
          submission_type: "file",
          title: file.title,
          url: url_helpers.download_timeline_event_file_path(file)
        }
      end

      links = latest_event.links.map do |link|
        {
          submission_type: "link",
          title: link[:title],
          url: link[:url]
        }
      end

      files + links
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
  end
end
