require 'rails_helper'

describe Users::AnalyticsStateService do
  include FounderSpecHelper

  subject { described_class.new(user) }

  context 'when user is a mooc student' do
    let(:mooc_student) { create :mooc_student, name: Faker::Name.name }
    let(:user) { mooc_student.user }

    it 'returns email and name' do
      expect(subject.state).to eq(
        email: mooc_student.email,
        name: mooc_student.name
      )
    end
  end

  context 'when user is a founder' do
    let!(:screening_target) { create :target, :admissions_screening }
    let!(:fee_payment_target) { create :target, :admissions_fee_payment }

    context 'when founder signed up' do
      let(:startup) { create :level_0_startup }
      let(:user) { startup.admin.user }

      it 'returns email, name and basic startup details' do
        expect(subject.state).to eq(
          email: startup.admin.email,
          name: startup.admin.name,
          startup: {
            id: startup.id,
            admissions_stage: Users::AnalyticsStateService::ADMISSION_STAGE_SIGNED_UP,
            product_name: startup.product_name
          }
        )
      end

      context 'when the founder has completed screening' do
        it 'returns admission stage as screening_complete' do
          complete_target(startup.admin, screening_target)

          expect(subject.state).to eq(
            email: startup.admin.email,
            name: startup.admin.name,
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
          create :payment, startup: startup

          expect(subject.state).to eq(
            email: startup.admin.email,
            name: startup.admin.name,
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
          complete_target(startup.admin, screening_target)
          complete_target(startup.admin, fee_payment_target)
          create :payment, :paid, startup: startup

          expect(subject.state).to eq(
            email: startup.admin.email,
            name: startup.admin.name,
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
          complete_target(startup.admin, screening_target)
          complete_target(startup.admin, fee_payment_target)

          expect(subject.state).to eq(
            email: startup.admin.email,
            name: startup.admin.name,
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
      let(:user) { startup.admin.user }

      it 'returns admission stage as admitted' do
        expect(subject.state).to eq(
          email: startup.admin.email,
          name: startup.admin.name,
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
