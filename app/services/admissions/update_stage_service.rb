module Admissions
  class UpdateStageService
    def initialize(startup, stage)
      @startup = startup
      @stage = stage
    end

    def execute
      @startup.update!(
        admission_stage: @stage,
        admission_stage_updated_at: Time.zone.now
      )
    end
  end
end
