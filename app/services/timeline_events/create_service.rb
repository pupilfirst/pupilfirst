module TimelineEvents
  class CreateService
    def initialize(params, founder)
      @params = params
      @founder = founder
      @target = params[:target]
    end

    def execute
      TimelineEvent.transaction do
        TimelineEvent.create!(@params).tap do |te|
          @founder.timeline_event_owners.create!(timeline_event: te, latest: true)
          create_team_entries(te) if @params[:target].team_target?
          WebhookDeliveries::CreateService.new(@founder.school, WebhookDelivery::SUBMISSION_CREATED_EVENT).execute(payload_for_webhook(te))
          update_latest_flag(te)
        end
      end
    end

    private

    def create_team_entries(timeline_event)
      team_members.each do |member|
        member.timeline_event_owners.create!(timeline_event: timeline_event, latest: true)
      end
    end

    def update_latest_flag(timeline_event)
      old_events = @target.timeline_events.joins(:timeline_event_owners)
        .where(timeline_event_owners: { founder: owners })
        .where.not(id: timeline_event)

      TimelineEventOwner.where(timeline_event_id: old_events, founder: owners).update_all(latest: false) # rubocop:disable Rails/SkipsModelValidations
    end

    def owners
      if @target.team_target?
        @founder.startup.founders
      else
        @founder
      end
    end

    def team_members
      @founder.startup.founders - [@founder]
    end

    def payload_for_webhook(submission)
      {
        id: submission.id,
        created_at: submission.created_at,
        updated_at: submission.updated_at,
        target_id: submission.target_id,
        checklist: submission.checklist,
        target: {
          id: submission.target.id,
          title: submission.target.title,
          evaluation_criteria: evaluation_criteria(submission.target)
        }
      }
    end

    def evaluation_criteria(submission)
      submission.evaluation_criteria.map do |ec|
        {
          name: ec.name,
          max_grade: ec.max_grade,
          pass_grade: ec.pass_grade,
          grade_labels: ec.grade_labels
        }
      end
    end
  end
end
