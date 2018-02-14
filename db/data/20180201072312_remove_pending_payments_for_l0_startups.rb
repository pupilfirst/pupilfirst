# This deletes pending payments that were created for startups in level 0. This deletion is required at this point
# of time because the action of adding team members caused the creation of pending payments; this was a requirement
# for the earlier admissions process, but with the current flow, these pending payments should have been created only
# after a team passed the interview round.
#
# This DOES NOT delete payment entries that are marked as 'paid', or 'requested' (registered with Instamojo).
#
# See Trello card for more details: https://trello.com/c/FWAMWdiU
class RemovePendingPaymentsForL0Startups < ActiveRecord::Migration[5.1]
  def up
    unrequested_payments = Payment.joins(:startup)  # Payments for startup
      .merge(Startup.level_zero)                    # ... in level zero
      .pending                                      # ... that aren't paid
      .where(instamojo_payment_request_status: nil) # ... and haven't been registered at Instamojo.

    unrequested_payments.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
