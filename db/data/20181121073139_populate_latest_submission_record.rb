class PopulateLatestSubmissionRecord < ActiveRecord::Migration[5.2]
  def up
    Founder.admitted.each do |founder|
      founder.startup.school.targets.each do |target|
        next if LatestSubmissionRecord.where(
          founder: founder,
          target: target
        ).present?

        latest_timeline_event = target.latest_linked_event(founder)

        next if latest_timeline_event.blank?

        TimelineEvents::UpdateLatestSubmissionRecordService.new(latest_timeline_event).execute
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
