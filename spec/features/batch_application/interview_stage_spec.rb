require 'rails_helper'

feature 'Application Interview Stage' do
  include UserSpecHelper

  let(:application_round) { create :application_round, :interview_stage }
  let(:batch_application) { create :batch_application, :interview_stage, application_round: application_round }
  let(:batch_applicant) { batch_application.team_lead }
  let(:interview_stage) { create :application_stage, :interview }

  context 'when interview stage is ongoing' do
    scenario 'user is shown ongoing state page' do
      sign_in_user(batch_applicant.user, referer: apply_continue_path)
      expect(page).to have_content("You’ve made it to the interviews!")
    end

    context 'when user has attended interview' do
      before do
        create(:application_submission, application_stage: interview_stage, batch_application: batch_application)
      end

      scenario 'user is shown submitted state page' do
        sign_in_user(batch_applicant.user, referer: apply_continue_path)
        expect(page).to have_content('It was great meeting you at the interview.')
      end
    end
  end

  context 'when interview stage is over' do
    before do
      RoundStage.find_by(application_round: application_round, application_stage: interview_stage).update!(ends_at: 1.day.ago)
    end

    context 'when applicant has not attended interview' do
      scenario 'user is shown expired state page' do
        sign_in_user(batch_applicant.user, referer: apply_continue_path)
        expect(page).to have_content("It looks like your team didn't attend the interviews")
      end
    end

    context 'when the applicant has attended interview' do
      before do
        create(:application_submission, application_stage: interview_stage, batch_application: batch_application)
      end

      scenario 'user is shown submitted state page' do
        sign_in_user(batch_applicant.user, referer: apply_continue_path)
        expect(page).to have_content('It was great meeting you at the interview.')
      end

      context 'when the batch has progressed to next stage' do
        let(:pre_selection_stage) { create(:application_stage, number: 6) }

        before do
          RoundStage.find_by(
            application_round: application_round, application_stage: interview_stage
          ).update!(ends_at: 4.days.ago)

          RoundStage.find_by(
            application_round: application_round, application_stage: pre_selection_stage
          ).update!(starts_at: 3.days.ago, ends_at: 4.days.from_now)
        end

        scenario 'user is shown rejected state page' do
          sign_in_user(batch_applicant.user, referer: apply_continue_path)
          expect(page).to have_content("but your team didn't make the cut during the interview process.")
        end
      end
    end
  end
end
