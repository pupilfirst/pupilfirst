require 'rails_helper'

feature 'Pre-selection Stage' do
  include BatchApplicantSpecHelper

  let(:batch) { create :batch, :in_stage_4 }
  let(:batch_application) { create :batch_application, :stage_4, batch: batch, team_size: 4 }

  before do
    batch_application.batch_applicants.update_all(fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE)
    @applicant_requiring_income_proof = batch_application.cofounders.last
    @applicant_requiring_income_proof.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP)
    sign_in_batch_applicant(batch_application.team_lead)
  end

  context 'when pre-selection stage is ongoing' do
    scenario 'user is shown ongoing state page' do
      expect(page).to have_content('Your Startup awaits!')
      expect(page).to have_content("You have been selected to Batch #{batch.batch_number} starting #{batch.start_date.strftime('%B %d, %Y')}")
      expect(page).to have_content('Transfer your total fee – ₹109,500')
    end

    def fill_in_applicant_profile_form(skip_current_address: false)
      select 'Product', from: 'Role'
      select 'Other', from: 'Gender'
      fill_in 'Date of Birth', with: '1990-01-01'
      fill_in "Parent's Name", with: Faker::Name.name
      fill_in 'Permanent Address', with: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")
      attach_file 'Proof of Address', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg'))

      unless skip_current_address
        fill_in 'Current Address', with: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")
      end

      fill_in 'Mobile Phone', with: '9876543210'
      select 'Driving License', from: 'Type of ID Proof'
      fill_in 'ID Proof Number', with: Faker::Internet.password
      attach_file 'Proof of Identity', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg'))
    end

    scenario 'user submits applicant profile' do
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'

      expect(page).to have_text("Editing #{batch_application.team_lead.name}'s Profile")

      fill_in_applicant_profile_form
      click_button 'Update Profile'

      expect(page).to have_text 'Complete. Edit'
    end

    scenario 'user submits applicant profile reusing permanent address', js: true do
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'

      expect(page).to have_text("Editing #{batch_application.team_lead.name}'s Profile")

      fill_in_applicant_profile_form(skip_current_address: true)
      check 'Is your current address same as your permanent address?'

      # The current address input should disappear.
      expect(page).to_not have_selector('#application_stage_four_applicant_current_address', visible: true)

      click_button 'Update Profile'

      expect(page).to have_text 'Complete. Edit'
      applicant = batch_application.team_lead.reload
      expect(applicant.current_address).to eq(applicant.permanent_address)
    end

    context 'when form is submitted empty' do
      it 'raises errors for required fields' do
        page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'
        click_button 'Update Profile'
        expect(page).to have_selector('.form-group.row.has-danger', count: 11)
      end
    end

    context 'when editing applicant requiring income proof' do
      it 'requires extra information from applicant' do
        visit apply_stage_path(stage_number: '4', update_profile: @applicant_requiring_income_proof.id)

        fill_in_applicant_profile_form

        attach_file 'Proof of Income', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))
        attach_file 'Letter from Parent', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-thumbnail.png'))
        fill_in 'College Contact Number', with: '8976543210'

        click_button 'Update Profile'

        expect(page).to have_text 'Complete. Edit'
      end

      context 'when form is submitted empty' do
        it 'raises errors for required fields' do
          visit apply_stage_path(stage_number: '4', update_profile: @applicant_requiring_income_proof.id)
          click_button 'Update Profile'
          expect(page).to have_selector('.form-group.row.has-danger', count: 14)
        end
      end
    end
  end

  context 'when pre-selection stage is over' do
    context 'when applicant has not submitted required documents' do
      scenario 'user is shown expired state page'
    end

    context 'when the applicant has attended submitted documents' do
      scenario 'user is shown submitted state page'

      context 'when the batch has progressed to next stage' do
        let(:stage_5) { create(:application_stage, number: 5) }

        before do
          BatchStage.find_by(batch: batch, application_stage: stage_4).update!(ends_at: 1.day.ago)
          create(:batch_stage, batch: batch, application_stage: stage_5, starts_at: 3.days.ago)
        end

        scenario 'user is shown rejected state page'
      end
    end
  end
end
