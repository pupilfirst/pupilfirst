class CreateNewPaymentsWithTypeRefundedForOldRefundedPayments < ActiveRecord::Migration[5.1]
  def up
    refunded_payments = Payment.where(refunded: true)
    refunded_payments.each do |refunded_payment|
      next if refunded_payment.amount.blank?
      Payment.create!(
        amount: refunded_payment.amount,
        notes: payment_note(refunded_payment.id, refunded_payment.instamojo_payment_id),
        payment_type: 'refund'
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def payment_note(id, instamojo_payment_id)
    "Refunded for payment - id: #{id}, instamojo_payment_id: #{instamojo_payment_id}"
  end
end
