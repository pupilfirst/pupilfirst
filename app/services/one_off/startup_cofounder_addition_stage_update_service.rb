module OneOff
  # There was a bug in updating 'Added Cofounder' stage for level 0 startups. This will update the applicable startups with this stage.
  class StartupCofounderAdditionStageUpdateService
    include Loggable

    def execute
      startups_in_screening_completed_stage = Startup.where(admission_stage: Startup::ADMISSION_STAGE_SCREENING_COMPLETED)

      log "Updating admission_stage for #{startups_in_screening_completed_stage.count} startups..."

      startups_in_screening_completed_stage.each do |startup|
        te = startup.timeline_events.where(target: cofounder_addition_target)&.first
        if te.present? && te.verified?
          startup.update!(admission_stage: Startup::ADMISSION_STAGE_COFOUNDERS_ADDED, admission_stage_updated_at: te.created_at)
        end
      end

      nil
    end

    private

    def cofounder_addition_target
      @cofounder_addition_target ||= Target.find_by(key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
    end
  end
end
