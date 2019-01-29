require 'rails_helper'

describe Users::AnalyticsStateService, broken: true do
  include FounderSpecHelper

  subject { described_class.new(user) }

  let(:user) do
    # This service relies on being supplied a `current_user`, which would have `current_founder` set.
    startup.founders.first.user.tap { |user| user.current_founder = startup.founders.first }
  end

  context 'when user is a founder' do
    let!(:screening_target) { create :target, :admissions_screening }
    let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition }
    let!(:fee_payment_target) { create :target }

    context 'when founder signed up' do
      let(:startup) { create :level_0_startup }

      it 'returns email, name and basic startup details' do
        expect(subject.state).to eq(
          email: startup.founders.first.email,
          name: startup.founders.first.name,
          startup: {
            id: startup.id,
            admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_SIGNED_UP,
            product_name: startup.product_name
          }
        )
      end

      context 'when the founder has completed screening' do
        it 'returns admission stage as screening_complete' do
          complete_target(startup.founders.first, screening_target)

          expect(subject.state).to eq(
            email: startup.founders.first.email,
            name: startup.founders.first.name,
            startup: {
              id: startup.id,
              admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_SCREENING_COMPLETE,
              product_name: startup.product_name
            }
          )
        end
      end

      context 'when founder has initiated payment' do
        it 'returns admission stage as payment_initiated' do
          complete_target(startup.founders.first, screening_target)
          complete_target(startup.founders.first, cofounder_addition_target)
          create :payment, startup: startup

          expect(subject.state).to eq(
            email: startup.founders.first.email,
            name: startup.founders.first.name,
            startup: {
              id: startup.id,
              admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_PAYMENT_INITIATED,
              product_name: startup.product_name
            }
          )
        end
      end

      context 'when founder has completed payment' do
        it 'returns admission stage as payment_completed' do
          complete_target(startup.founders.first, screening_target)
          complete_target(startup.founders.first, cofounder_addition_target)
          complete_target(startup.founders.first, fee_payment_target)
          create :payment, :paid, startup: startup

          expect(subject.state).to eq(
            email: startup.founders.first.email,
            name: startup.founders.first.name,
            startup: {
              id: startup.id,
              admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_PAYMENT_COMPLETED,
              product_name: startup.product_name
            }
          )
        end
      end

      context 'when founder has bypassed payment' do
        it 'returns admission stage as payment_bypassed' do
          complete_target(startup.founders.first, screening_target)
          complete_target(startup.founders.first, cofounder_addition_target)
          complete_target(startup.founders.first, fee_payment_target)

          expect(subject.state).to eq(
            email: startup.founders.first.email,
            name: startup.founders.first.name,
            startup: {
              id: startup.id,
              admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_PAYMENT_BYPASSED,
              product_name: startup.product_name
            }
          )
        end
      end
    end

    context 'when founder is part of an admitted startup' do
      let(:startup) { create :startup }

      it 'returns admission stage as admitted' do
        expect(subject.state).to eq(
          email: startup.founders.first.email,
          name: startup.founders.first.name,
          startup: {
            id: startup.id,
            admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_ADMITTED,
            product_name: startup.product_name
          }
        )
      end
    end
  end
end
