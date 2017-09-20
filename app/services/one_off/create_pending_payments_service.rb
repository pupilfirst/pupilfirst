module OneOff
  # This one-off service creates pending payments for founders who have added cofounders, but didn't click the
  # pay-now button on the old admissions fee page.
  #
  # The new payment flow creates a pending payment once one or more founders are added at the founder edit page. The
  # is the retroactive equivalent.
  class CreatePendingPaymentsService
    include Loggable

    def execute
      results = { skipped: [], created: [] }

      Startup.where(admission_stage: Startup::ADMISSION_STAGE_COFOUNDERS_ADDED).each do |startup|
        if startup.payments.any?
          log "Startup ##{startup.id} is in cofounders added stage, but has a payment entry. Odd."
          results[:skipped] << startup.id
          next
        end

        payment = Payments::CreateService.new(startup.team_lead).create
        log "Created Payment ##{payment.id} for Startup ##{startup.id}"
        results[:created] << startup.id
      end

      results
    end
  end
end
