module Admissions
  class PaymentForm < Reform::Form
    def save
      startup = model.startup
      payment = startup.payments.requested.last

      Startup.transaction do
        # If requested payment is present
        if payment.present?
          # and the amount is the same as last time
          if payment.amount == startup.fee
            # just return the payment
            payment
          else
            # otherwise archive the old one
            payment.archive!

            # and create a new payment.
            create_new_payment
          end
        else
          # If payment doesn't exist, create a new one.
          create_new_payment
        end
        startup.update!(admission_stage: Startup::ADMISSION_STAGE_PAYMENT_INITIATED)
        Intercom::LevelZeroStageUpdateJob.perform_later(model, 'Payment Initiated')
      end

      startup.reload.payments.requested.last
    end

    def create_new_payment
      Payments::CreateService.new(model).execute
    end
  end
end
