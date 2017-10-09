module ProductMetrics
  class CollectMetricsService
    def execute
      automatic_categories.each do |category, delta_period|
        method_postfix = category.downcase.tr(' ', '_').strip

        ProductMetric.create!(
          value: send("count_#{method_postfix}"),
          delta_period: delta_period
        )
      end
    end

    private

    def automatic_categories
      ProductMetric::VALID_CATEGORIES.each do |key, value|
        yield key, value[:delta_period] if key[:automatic]
      end
    end

    # Number of admitted startups.
    def count_startups
      Startup.admitted.count
    end

    # Number of admitted founders.
    def count_founder
      Founder.admitted.count
    end

    # Number of states with admitted founders.
    def count_participating_states
      College.joins(:founders, :state).merge(Founder.admitted).distinct(:state_id).count
    end

    # Number of universities with admitted founders.
    def count_participating_universities
      College.joins(:founders, :university).merge(Founder.admitted).distinct(:university_id).count
    end

    # Number of colleges with admitted founders.
    def count_participating_colleges
      College.joins(:founders).merge(Founder.admitted).distinct.count
    end

    # Number of founders before Level A.
    def count_student_explorers
      # wip
    end

    # Number of founder in Level B-C.
    def count_student_alpha_engineers
      # wip
    end

    # Number of founders in Level D-E.
    def count_student_beta_engineers
      # wip
    end

    # Number of live targets.
    def count_targets
      Target.live.count
    end

    # Number of visible faculty session targets.
    def count_faculty_sessions
      Target.sessions.live.count
    end

    # Number of hours spent in faculty connect sessions.
    def count_faculty_office_hours
      ConnectRequest.completed.count / 2
    end

    # Number of resources.
    def count_library_resources
      Resource.count
    end

    # Number of downloads of resources.
    def count_library_resource_downloads
      Resource.all.sum(:downloads)
    end

    # Time spent in days by founders on website.
    def count_time_spent_on_website
      Visit.joins(:founders)
    end
  end
end
