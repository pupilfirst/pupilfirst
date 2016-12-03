module Targets
  class StatusService
    STATUS_PENDING = :pending
    STATUS_EXPIRED = :expired
    STATUS_COMPLETE = :complete
    STATUS_UNAVAILABLE = :unavailable

    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def status
      return STATUS_COMPLETE if complete?
      return STATUS_EXPIRED if due_date_past?
      return STATUS_PENDING if prerequisites_complete?
      STATUS_UNAVAILABLE
    end

    def pending_prerequisites
      return unless status == STATUS_UNAVAILABLE

      # Return array of pending prerequisite targets.
      raise NotImplementedError
    end

    private

    def complete?
      raise NotImplementedError
    end

    def due_date_past?
      raise NotImplementedError
    end

    def prerequisites_complete?
      raise NotImplementedError
    end
  end
end
