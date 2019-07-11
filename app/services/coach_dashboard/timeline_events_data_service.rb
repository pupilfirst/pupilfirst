module CoachDashboard
  class TimelineEventsDataService
    def initialize(faculty, course, review_status = :pending, excluded_ids = [], limit = 20)
      @faculty = faculty
      @course = course
      @review_status = review_status
      @excluded_ids = excluded_ids
      @limit = limit
    end

    def timeline_events
      @timeline_events ||= ordered_timeline_events.map(&method(:timeline_event_fields))
    end

    def more_to_load?
      @more_to_load ||= filtered_events.where.not(id: ordered_timeline_events.pluck(:id)).exists?
    end

    def earliest_submission_date
      @earliest_submission_date ||= more_to_load? ? ordered_timeline_events.last.created_at.strftime("%b %d, %Y") : nil
    end

    private

    def ordered_timeline_events
      @ordered_timeline_events ||= begin
        filtered_events.includes(:timeline_event_owners, :timeline_event_files, :startup_feedback, :timeline_event_grades)
          .includes(target: :level)
          .includes(:target_evaluation_criteria, :evaluation_criteria)
          .includes(evaluator: { user: :avatar_attachment })
          .order(created_at: :DESC).limit(@limit)
      end
    end

    def filtered_events
      @filtered_events ||= begin
        timeline_events = @review_status == :pending ? TimelineEvent.pending_review : TimelineEvent.evaluated_by_faculty
        timeline_events.from_founders(founders).where.not(id: @excluded_ids)
      end
    end

    def founders
      teams = @faculty.reviewable_startups(@course)
      Founder.where(startup_id: teams)
    end

    def timeline_event_fields(timeline_event)
      {
        id: timeline_event.id,
        title: title(timeline_event),
        description: timeline_event.description,
        createdAt: timeline_event.created_at,
        founderIds: founder_ids(timeline_event),
        links: timeline_event.links,
        files: files(timeline_event),
        latestFeedback: timeline_event.startup_feedback&.last&.feedback,
        evaluation: evaluation(timeline_event),
        rubric: rubric(timeline_event),
        evaluator: evaluator(timeline_event)
      }
    end

    def title(timeline_event)
      timeline_event.target.level.short_name + ' | ' + timeline_event.target.title
    end

    def founder_ids(timeline_event)
      timeline_event.timeline_event_owners.map(&:founder_id)
    end

    def files(timeline_event)
      timeline_event.timeline_event_files.map { |file| { title: file.title, id: file.id } }
    end

    def evaluation(timeline_event)
      timeline_event.evaluation_criteria.map do |criterion|
        {
          criterionId: criterion.id.to_s,
          criterionName: criterion.name,
          grade: @review_status == :pending ? nil : grade(timeline_event, criterion)
        }
      end
    end

    def grade(timeline_event, criterion)
      timeline_event.timeline_event_grades&.find_by(evaluation_criterion_id: criterion.id)&.grade
    end

    def rubric(timeline_event)
      timeline_event.target.rubric_description
    end

    def evaluator(timeline_event)
      timeline_event.evaluator&.name
    end
  end
end
