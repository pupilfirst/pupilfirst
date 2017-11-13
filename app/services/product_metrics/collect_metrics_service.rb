module ProductMetrics
  class CollectMetricsService
    include Loggable

    def execute
      automatic_categories do |category, delta_period|
        method_postfix = category.downcase.tr(' ', '_').strip

        ProductMetric.create!(
          category: category,
          value: send("count_#{method_postfix}"),
          delta_period: delta_period,
          assignment_mode: ProductMetric::ASSIGNMENT_MODE_AUTOMATIC
        )
      end
    end

    private

    def automatic_categories
      ProductMetric::VALID_CATEGORIES.each do |key, value|
        if value[:automatic]
          log "Recording #{key}..."
          yield key, value[:delta_period]
        end
      end
    end

    # Number of admitted startups.
    def count_startups
      Startup.admitted.count
    end

    # Number of admitted founders.
    def count_founders
      Founder.admitted.count
    end

    # Number of states with admitted founders.
    def count_participating_states
      College.joins({ founders: { startup: :level } }, :state).merge(Founder.admitted).distinct(:state_id).count(:state_id)
    end

    # Number of universities with admitted founders.
    def count_participating_universities
      College.joins({ founders: { startup: :level } }, :university).merge(Founder.admitted).distinct(:university_id).count(:university_id)
    end

    # Number of colleges with admitted founders.
    def count_participating_colleges
      College.joins(founders: { startup: :level }).merge(Founder.admitted).distinct.count
    end

    # Number of founders on or before level 3.
    def count_student_explorers
      Founder.joins(startup: :level).where(levels: { number: [1, 2, 3] }).count
    end

    # Number of founder in Level 4 or 5.
    def count_student_alpha_engineers
      Founder.joins(startup: :level).where(levels: { number: [4, 5] }).count
    end

    # Number of founders in Level 6.
    def count_student_beta_engineers
      Founder.joins(startup: :level).where(levels: { number: 6 }).count
    end

    # Number of live targets.
    def count_targets
      Target.live.count
    end

    # Number of visible faculty session targets.
    def count_faculty_sessions
      Target.sessions.live.count
    end

    # Number of faculty connect sessions.
    def count_faculty_office_hours
      ConnectRequest.completed.count
    end

    # Number of resources.
    def count_library_resources
      Resource.count
    end

    # Number of downloads of resources.
    def count_library_resource_downloads
      Resource.all.sum(:downloads)
    end

    # Number of recorded messages on Public Slack.
    def count_slack_messages
      PublicSlackMessage.count
    end

    def count_timeline_events
      TimelineEvent.verified.joins(:startup).merge(Startup.admitted).count
    end
  end
end
