module FacultyModule
  # Finds and returns the timeline events that a
  class ReviewableTimelineEventsService
    def initialize(faculty)
      @faculty = faculty
    end

    def timeline_events(course)
      founder_ids = Founder.where(startup: @faculty.reviewable_startups(course)).select(:id)

      TimelineEvent.not_auto_verified.joins(:timeline_event_owners)
        .includes(:founders, :evaluation_criteria, :timeline_event_files, :startup_feedback, :timeline_event_owners)
        .includes(:target_evaluation_criteria, target: :level)
        .where(timeline_event_owners: { founder_id: founder_ids })
        .order(created_at: :DESC).limit(100).map { |timeline_event| timeline_event_fields(timeline_event) }
    end

    def timeline_event_fields(timeline_event)
      {
        id: timeline_event.id,
        title: title(timeline_event),
        description: timeline_event.description,
        eventOn: timeline_event.event_on,
        status: timeline_event.status,
        startupId: timeline_event.founders.first&.startup_id,
        startupName: timeline_event.startup.product_name,
        founders: timeline_event.founders.map { |founder| { id: founder.id, name: founder.name } },
        links: timeline_event.links,
        files: timeline_event.timeline_event_files.map { |file| { title: file.title, id: file.id } },
        image: timeline_event.image? ? timeline_event.image.url : nil,
        latestFeedback: timeline_event.startup_feedback&.last&.feedback,
        evaluation: evaluation(timeline_event),
        rubric: rubric(timeline_event)
      }
    end

    def title(timeline_event)
      timeline_event.target.level.short_name + ' | ' + timeline_event.target.title
    end

    def evaluation(timeline_event)
      timeline_event.evaluation_criteria.map do |criterion|
        {
          criterionId: criterion.id,
          criterionName: criterion.name,
          grade: timeline_event.timeline_event_grades&.find_by(evaluation_criterion: criterion)&.grade
        }
      end
    end

    def rubric(timeline_event)
      timeline_event.target.rubric_description
    end
  end
end
