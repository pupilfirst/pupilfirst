module FacultyModule
  # Finds and returns the timeline events that a
  class ReviewableTimelineEventsService
    def initialize(faculty)
      @faculty = faculty
    end

    def timeline_events(school)
      faculty_courses = @faculty.courses.where(school: school)
      course_startups = Startup.joins(level: :course).where(levels: { courses: { id: faculty_courses.select(:id) } })

      faculty_startups = @faculty.startups.joins(level: { course: :school })
        .where(levels: { courses: { school: school } })

      # The supplied faculty is concerned with submissions from the startups to which zhe is directly linked, and the
      # startups that belong to the courses which zhe directly administer.
      startup_ids = course_startups.pluck(:id) + faculty_startups.pluck(:id)
      unique_startup_ids = startup_ids.uniq

      TimelineEvent.not_auto_verified.joins(:startup)
        .where(startups: { id: unique_startup_ids })
        .includes(:founder, :startup, :timeline_event_files, :startup_feedback)
        .order(created_at: :DESC).limit(50).map { |timeline_event| timeline_event_fields(timeline_event) }
    end

    def timeline_event_fields(timeline_event)
      {
        id: timeline_event.id,
        title: title(timeline_event),
        description: timeline_event.description,
        eventOn: timeline_event.event_on,
        status: timeline_event.status,
        startupId: timeline_event.startup_id,
        startupName: timeline_event.startup.product_name,
        founderId: timeline_event.founder_id,
        founderName: timeline_event.founder.name,
        links: timeline_event.links,
        files: timeline_event.timeline_event_files.map { |file| { title: file.title, id: file.id } },
        image: timeline_event.image? ? timeline_event.image.url : nil,
        grade: timeline_event.overall_grade_from_score,
        latestFeedback: timeline_event.startup_feedback&.last&.feedback
      }
    end

    def title(timeline_event)
      timeline_event.target.level.short_name + ' | ' + timeline_event.target.title
    end
  end
end
