module Admissions
  class PaymentForm < Reform::Form
    def save
      Startup.transaction do
        # If payment is present
        if model.payment.present?
          # and the amount is the same as last time
          if model.payment.amount == model.fee
            # just return the payment
            model.payment
          else
            # otherwise archive the old one
            model.payment.archive!

            # and create a new payment.
            create_new_payment
          end
        else
          # If payment doesn't exist, create a new one.
          create_new_payment
        end

        IntercomLastApplicantEventUpdateJob.perform_later(model.team_lead, 'payment_initiated') unless Rails.env.test?
      end

      model.payment
    end

    def create_new_payment
      PaymentCreateService.new(model).execute
    end
  end
end
