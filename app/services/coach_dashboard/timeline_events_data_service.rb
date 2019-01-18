module CoachDashboard
  class TimelineEventsDataService
    def initialize(faculty, course, review_status = :pending, excluded_ids = [], limit = 50)
      @faculty = faculty
      @course = course
      @review_status = review_status
      @excluded_ids = excluded_ids
      @limit = limit
    end

    def timeline_events
      @timeline_events ||= begin
        filtered_events
          .includes(:timeline_event_owners, :timeline_event_files, :startup_feedback)
          .includes(target: :level)
          .includes(:target_evaluation_criteria, :evaluation_criteria)
          .order(created_at: :DESC).limit(@limit).map { |timeline_event| timeline_event_fields(timeline_event) }
      end
    end

    def more_to_load?
      filtered_events.where.not(id: timeline_events.map { |te| te[:id] }).exists?
    end

    private

    def filtered_events
      timeline_events = @review_status == :pending ? TimelineEvent.pending_review : TimelineEvent.evaluated_by_faculty
      timeline_events.from_founders(founders).where.not(id: @excluded_ids)
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
        eventOn: timeline_event.event_on,
        founderIds: founder_ids(timeline_event),
        links: timeline_event.links,
        files: files(timeline_event),
        image: timeline_event.image? ? timeline_event.image.url : nil,
        latestFeedback: timeline_event.startup_feedback&.last&.feedback,
        evaluation: evaluation(timeline_event),
        rubric: rubric(timeline_event)
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
          criterionId: criterion.id,
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
  end
end
