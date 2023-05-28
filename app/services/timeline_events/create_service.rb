module TimelineEvents
  class CreateService
    def initialize(
      params,
      student,
      notification_service: Developers::NotificationService.new
    )
      @params = params
      @student = student
      @target = params[:target]
      @notification_service = notification_service
    end

    def execute
      submission =
        TimelineEvent.transaction do
          timeline_event_params =
            @target.evaluation_criteria.blank? ? @params.merge(passed_at: Time.zone.now) :
              @params
          TimelineEvent
            .create!(timeline_event_params)
            .tap do |s|
              @student.timeline_event_owners.create!(
                timeline_event: s,
                latest: true
              )

              create_team_entries(s) if @params[:target].team_target?

              update_latest_flag(s)
            end
        end

      @notification_service.execute(
        @student.course,
        :submission_created,
        @student.user,
        submission
      )

      submission
    end

    private

    def create_team_entries(timeline_event)
      team_members.each do |member|
        member.timeline_event_owners.create!(
          timeline_event: timeline_event,
          latest: true
        )
      end
    end

    def update_latest_flag(timeline_event)
      TimelineEventOwner
        .where(
          timeline_event_id: old_events(timeline_event).live,
          student: owners
        )
        .update_all(latest: false) # rubocop:disable Rails/SkipsModelValidations
    end

    def owners
      if (@target.team_target? && @student.team)
        @student.team.students
      else
        @student
      end
    end

    def team_members
      @student.team ? @student.team.students - [@student] : []
    end

    def old_events(timeline_event)
      @target
        .timeline_events
        .joins(:timeline_event_owners)
        .where(timeline_event_owners: { student: owners })
        .where.not(id: timeline_event)
    end
  end
end
