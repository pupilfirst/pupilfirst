require 'rails_helper'

feature 'Application Interview Stage' do
  include UserSpecHelper

  let(:batch) { create :batch, :in_stage_3 }
  let(:batch_applicant) { batch_application.team_lead }
  let!(:batch_application) { create :batch_application, :stage_3, batch: batch }
  let(:stage_3) { create :application_stage, number: 3 }

  before do
    sign_in_user(batch_applicant.user, referer: apply_continue_path)
  end

  context 'when interview stage is ongoing' do
    scenario 'user is shown ongoing state page' do
      visit apply_continue_path
      expect(page).to have_content("You've made it to the interviews!")
    end

    context 'when user has attended interview' do
      before do
        create(:application_submission, application_stage: stage_3, batch_application: batch_application)
      end

      scenario 'user is shown submitted state page' do
        visit apply_continue_path
        expect(page).to have_content('It was great meeting you at the interview.')
      end
    end
  end

  context 'when interview stage is over' do
    before do
      BatchStage.find_by(batch: batch, application_stage: stage_3).update!(ends_at: 1.day.ago)
    end

    context 'when applicant has not attended interview' do
      scenario 'user is shown expired state page' do
        visit apply_continue_path
        expect(page).to have_content("It looks like your team didn't attend the interviews")
      end
    end

    context 'when the applicant has attended interview' do
      before do
        create(:application_submission, application_stage: stage_3, batch_application: batch_application)
      end

      scenario 'user is shown submitted state page' do
        visit apply_continue_path
        expect(page).to have_content('It was great meeting you at the interview.')
      end

      context 'when the batch has progressed to next stage' do
        let(:stage_4) { create(:application_stage, number: 4) }

        before do
          BatchStage.find_by(batch: batch, application_stage: stage_3).update!(ends_at: 1.day.ago)
          create(:batch_stage, batch: batch, application_stage: stage_4, starts_at: 3.days.ago, ends_at: 4.days.from_now)
        end

        scenario 'user is shown rejected state page' do
          visit apply_continue_path
          expect(page).to have_content("but your team didn't make the cut during the interview process.")
        end
      end
    end
  end
end
