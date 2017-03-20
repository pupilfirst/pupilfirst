require 'rails_helper'

RSpec.describe BatchApplication, type: :model do
  subject { create :batch_application }

  let(:expected_course_fee) { 37_500 }

  describe '#applicant_course_fee' do
    context 'when supplied an applicant' do
      let(:applicant) { create :batch_applicant }

      context 'when applicant is not part of application' do
        it 'raises error' do
          expect do
            subject.applicant_course_fee(applicant)
          end.to raise_error("BatchApplicant##{applicant.id} does not belong BatchApplication##{subject.id}")
        end
      end

      context 'when applicant is a coapplicant' do
        let!(:payment) { create :payment, batch_applicant: subject.team_lead, batch_application: subject }

        before do
          subject.batch_applicants << applicant
        end

        context 'when applicant payment method is regular fee' do
          let(:applicant) { create :batch_applicant, fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE }

          context 'when team head also has regular fee' do
            it 'returns full course fee' do
              subject.team_lead.update!(fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE)
              expect(subject.applicant_course_fee(applicant)).to eq(expected_course_fee)
            end
          end

          context 'when team lead has scholarship' do
            it 'returns discounted course fee' do
              subject.team_lead.update!(fee_payment_method: BatchApplicant::PAYMENT_METHOD_MERIT_SCHOLARSHIP)
              expect(subject.applicant_course_fee(applicant)).to eq(expected_course_fee - payment.amount)
            end
          end
        end

        context 'when applicant payment method is other' do
          it 'returns zero' do
            expect(subject.applicant_course_fee(applicant)).to eq(0)
          end
        end
      end

      context 'when applicant is team lead' do
        before do
          subject.batch_applicants << applicant
          subject.update!(team_lead: applicant)
        end

        context 'when payment method is regular fee' do
          let(:applicant) { create :batch_applicant, fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE }

          context 'when payment is missing' do
            it 'returns full course fee' do
              expect(subject.applicant_course_fee(applicant)).to eq(expected_course_fee)
            end
          end

          context 'when payment has been skipped' do
            let!(:payment) { create :payment, batch_applicant: applicant, batch_application: subject, amount: nil }

            it 'returns full course fee' do
              expect(subject.applicant_course_fee(applicant)).to eq(expected_course_fee)
            end
          end

          context 'when payment has been completed' do
            context 'when payment has not been refunded' do
              let!(:payment) { create :payment, batch_applicant: applicant, batch_application: subject }

              it 'returns discounted course fee' do
                expect(subject.applicant_course_fee(applicant)).to eq(expected_course_fee - payment.amount)
              end
            end

            context 'when payment has been refunded' do
              let!(:payment) { create :payment, batch_applicant: applicant, batch_application: subject, refunded: true }

              it 'returns full course fee' do
                expect(subject.applicant_course_fee(applicant)).to eq(expected_course_fee)
              end
            end
          end
        end

        context 'when payment_method is other' do
          let(:applicant) { create :batch_applicant, fee_payment_method: BatchApplicant::PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP }

          it 'returns zero' do
            expect(subject.applicant_course_fee(applicant)).to eq(0)
          end
        end
      end
    end
  end

  describe '#total_course_fee' do
    subject { create :batch_application, :pre_selection_stage }
    let(:payment) { create :payment, batch_applicant: subject.team_lead, batch_application: subject }

    before do
      subject.batch_applicants.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE)
    end

    it 'returns sum of course fee for applicants' do
      expected_total_fee = expected_course_fee * subject.batch_applicants.count - payment.amount
      expect(subject.reload.total_course_fee).to eq(expected_total_fee)
    end
  end
end
