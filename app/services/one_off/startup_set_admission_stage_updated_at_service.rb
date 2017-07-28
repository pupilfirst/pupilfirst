module OneOff
  # This sets the admission_stage_updated_at
  class StartupSetAdmissionStageUpdatedAtService
    include Loggable

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    def execute
      startups_with_admission_stage = Startup.where.not(admission_stage: nil)

      log "Updating admission_stage_updated_at for #{startups_with_admission_stage.count} startups..."

      startups_with_admission_stage.each do |startup|
        case startup.admission_stage
          when Startup::ADMISSION_STAGE_SIGNED_UP
            startup.admission_stage_updated_at = startup.created_at
          when Startup::ADMISSION_STAGE_SCREENING_COMPLETED
            startup.admission_stage_updated_at = timeline_event_at(startup, Target::KEY_ADMISSIONS_SCREENING)
          when Startup::ADMISSION_STAGE_COFOUNDERS_ADDED
            startup.admission_stage_updated_at = timeline_event_at(startup, Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
          when Startup::ADMISSION_STAGE_PAYMENT_INITIATED
            startup.admission_stage_updated_at = startup.payment.created_at
          when Startup::ADMISSION_STAGE_FEE_PAID
            startup.admission_stage_updated_at = timeline_event_at(startup, Target::KEY_ADMISSIONS_FEE_PAYMENT)
          when Startup::ADMISSION_STAGE_ADMITTED
            startup.admission_stage_updated_at = startup.timeline_events.joins(:timeline_event_type).where(timeline_event_types: { key: TimelineEventType::TYPE_JOINED_SV_CO }).first&.created_at
          else
            raise "StartupSetAdmissionStageUpdatedAtService is unable to handle admission_stage '#{startup.admission_stage}'"
        end

        log "Startup ##{startup.id} changed to ##{startup.admission_stage} at #{startup.admission_stage_updated_at}"
        startup.save!
      end

      nil
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

    private

    def timeline_event_at(startup, target_key)
      target = Target.find_by(key: target_key)
      startup.timeline_events.find_by(target: target).created_at
    end
  end
end
