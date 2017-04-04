module Admissions
  class PaymentForm < Reform::Form
    def save
      startup = model.startup

      Startup.transaction do
        # If payment is present
        if startup.payment.present?
          # and the amount is the same as last time
          if startup.payment.amount == startup.fee
            # just return the payment
            startup.payment
          else
            # otherwise archive the old one
            startup.payment.archive!

            # and create a new payment.
            create_new_payment
          end
        else
          # If payment doesn't exist, create a new one.
          create_new_payment
        end

        IntercomLastApplicantEventUpdateJob.perform_later(startup.admin, 'payment_initiated') unless Rails.env.test?
      end

      startup.payment
    end

    def create_new_payment
      PaymentCreateService.new(model).execute
    end
  end
end
