class UpdatePaymentTypeToNormalForOldPayments < ActiveRecord::Migration[5.1]
  def up
    renewal_payments = Payment.where(payment_type: 'renewal')
    admission_payments = Payment.where(payment_type: 'admission')

    applicable_payments = renewal_payments + admission_payments

    applicable_payments.each do |payment|
      payment.update!(payment_type: 'normal')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
