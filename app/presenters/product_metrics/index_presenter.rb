module ProductMetrics
  class IndexPresenter < ApplicationPresenter
    PROGRAM_METRICS = {
      'Targets' => :targets,
      'Timeline Events' => :timeline_events,
      'Hours of Learning' => :hours_of_learning,
      'Slack Messages' => :slack,
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
  end
end
