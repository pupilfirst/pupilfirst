module OneOff
  # Service to create latest submission record for all targets
  class CreateLatestSubmissionRecordForAllTargets
    def execute
      Founder.all.each do |founder|
        course = founder.startup.course
        course.targets.each do |target|
          latest_timeline_event = target.latest_linked_event(founder)
          TimelineEvents::UpdateLatestSubmissionRecordService.new(latest_timeline_event).execute
        end
      end
    end
  end
end
