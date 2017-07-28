require 'rails_helper'

describe Payments::BillingService do
  subject { described_class }

  describe '#execute' do
    # Create three startups
    let!(:startup_1) { create :startup }
    let!(:startup_2) { create :startup }
    let!(:startup_3) { create :startup }

    # Create payments for the 3 startups with different dates for subscription expiry
    let!(:payment_expiring_in_six_days) { create :payment, :paid, billing_end_at: 6.days.from_now, startup: startup_3 }
    let!(:payment_expiring_in_three_days) { create :payment, :paid, billing_end_at: 3.days.from_now, startup: startup_2 }

    context 'when one startup is five days from expiry and another is three days from expiry' do
      let!(:payment_expiring_in_five_days) { create :payment, :paid, billing_end_at: 5.days.from_now, startup: startup_1 }
      let!(:payment_for_startup_2) { create :payment, :requested, billing_end_at: 30.days.from_now, startup: startup_2 }

      it 'creates new payment for startup whose subscription ends in 5 days' do
        subject.new.execute

        pending_payment_created = Payment.last
        expect(pending_payment_created.startup).to eq(startup_1)
        expect(pending_payment_created.billing_start_at.to_i).to eq(payment_expiring_in_five_days.billing_end_at.to_i)
        expect(pending_payment_created.billing_end_at.to_i).to eq((payment_expiring_in_five_days.billing_end_at + 1.month).to_i)
      end

      it 'sends reminder email for startups with payments expiring in 5 days and 3 days' do
        expect { subject.new.execute }.to change { Payment.count }.by(1).and change { ActionMailer::Base.deliveries.count }.by(2)

        open_email(startup_1.admin.email)
        expect(current_email).to have_content("Your SV.CO subscription expires in 5 days. To continue having access to our services please pay the monthly subscription fee of ₹#{startup_1.fee}")
        open_email(startup_2.admin.email)
        expect(current_email).to have_content("Your SV.CO subscription expires in 3 days. To continue having access to our services please pay the monthly subscription fee of ₹#{startup_2.fee}")
      end
    end

    context "when a startup's payment expires in three days, but has paid after the first reminder" do
      let!(:payment_for_startup_2) { create :payment, :paid, billing_end_at: 30.days.from_now, startup: startup_2 }

      it 'creates new payment for startup whose subscription ends in 5 days, sends reminder email for startups with payments expiring in 5 days' do
        expect { subject.new.execute }.to(not_change { Payment.count }.and(not_change { ActionMailer::Base.deliveries.count }))
      end
    end
  end
end
