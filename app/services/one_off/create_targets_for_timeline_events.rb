module OneOff
  class CreateTargetsForTimelineEvents
    def execute
      timeline_event_type_collection.each do |timeline_event_type_key|
        timeline_event_type = TimelineEventType.find_by(key: timeline_event_type_key)

        target = Target.where(
          title: timeline_event_type_key
        ).first_or_create!(
          timeline_event_type: timeline_event_type,
          days_to_complete: 1,
          role: Target::ROLE_TEAM,
          target_group: level_one_target_group,
          description: "Created for adding targets for all timeline events that lack one.",
          faculty: faculty,
          target_action_type: Target::TYPE_TODO,
          archived: true
        )

        timeline_event_collection = TimelineEvent.where(target_id: nil).where(timeline_event_type: timeline_event_type)

        # rubocop:disable Rails/SkipsModelValidations
        timeline_event_collection.update_all(target_id: target.id)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    private

    def timeline_event_type_collection
      TimelineEvent.joins(:timeline_event_type).where(target_id: nil).distinct(:key).pluck(:key)
    end

    def level_one_target_group
      @level_one_target_group ||= begin
        level_one = School.find_by(name: "Startup").levels.find_by(number: 1)
        level_one.target_groups.first
      end
    end

    def faculty
      @faculty ||= Faculty.find_by(name: "Vishnu Gopal")
    end
  end
end
