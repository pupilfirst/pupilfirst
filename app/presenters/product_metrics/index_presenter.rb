module ProductMetrics
  class IndexPresenter < ApplicationPresenter
    PROGRAM_METRICS = {
      'Slack Messages' => :slack,
      'Targets' => :targets,
      'Faculty Sessions' => :faculty_sessions,
      'Faculty Office Hours' => :office_hours,
      'Library Resources' => :resources,
      'Library Resource Downloads' => :resource_downloads,
      'Graduation Partners' => :graduation_partners,
      'Community Architects' => :community_architects,
      'Blog Stories Published' => :published_stories
    }.freeze

    MEMBER_JOURNEY = {
      'Student Explorers' => :explorers,
      'Student Alpha Engineers' => :alpha_engineers,
      'Student Beta Engineers' => :beta_engineers,
      'Heroes' => :heroes,
      'Leadership Team Members' => :leadership,
      'Coaches' => :coaches
    }.freeze

    def program_metrics
      PROGRAM_METRICS.keys
    end

    def member_journey_points
      MEMBER_JOURNEY.keys
    end

    def program_metric_icon(metric)
      return PROGRAM_METRICS[metric] if PROGRAM_METRICS.key?(PROGRAM_METRICS)
      raise "Cannot resolve icon for metric '#{metric}'"
    end
  end
end
