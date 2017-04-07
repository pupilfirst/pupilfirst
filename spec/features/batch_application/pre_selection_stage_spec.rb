require 'rails_helper'

feature 'Pre-selection Stage', disabled: true do
  include UserSpecHelper

  let(:application_round) { create :application_round, :pre_selection_stage }
  let(:batch_applicant) { batch_application.team_lead }
  let!(:batch_application) { create :batch_application, :pre_selection_stage, application_round: application_round, team_size: 4 }
  let(:image_path) { File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg')) }
  let(:pdf_path) { File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }

  context 'when the team lead has scholarship' do
    before do
      batch_application.batch_applicants.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE)
      batch_application.team_lead.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_MERIT_SCHOLARSHIP)
      batch_application.cofounders.last.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP)
      sign_in_user(batch_applicant.user, referer: apply_continue_path)
    end

    scenario 'another applicant receives the 3000 rupee refund' do
      expect(page).to have_content('Transfer your total fee – ₹72,000')
    end
  end

  context 'at the beginning of pre-selection stage' do
    before do
      batch_application.batch_applicants.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE)
      @applicant_requiring_income_proof = batch_application.cofounders.last
      @applicant_requiring_income_proof.update(fee_payment_method: BatchApplicant::PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP)
      sign_in_user(batch_applicant.user, referer: apply_continue_path)
    end

    scenario 'user is shown ongoing state page' do
      expect(page).to have_content('Your Startup awaits!')
      expect(page).to have_content('This is the first step on an exciting journey that will help you build a startup')
      expect(page).to have_content('Transfer your total fee – ₹109,500')
    end

    def fill_in_applicant_profile_form(skip_current_address: false)
      select 'Product', from: 'Role'
      select 'Other', from: 'Gender'
      fill_in 'Date of Birth', with: '1990-01-01'
      fill_in "Parent's Name", with: Faker::Name.name
      fill_in 'Permanent Address', with: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")
      attach_file 'Proof of Address', image_path

      unless skip_current_address
        fill_in 'Current Address', with: [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")
      end

      fill_in 'Mobile Phone', with: '9876543210'
      select 'Driving License', from: 'Type of ID Proof'
      fill_in 'ID Proof Number', with: Faker::Internet.password
      attach_file 'Proof of Identity', image_path
    end

    scenario 'user submits applicant profile' do
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'

      expect(page).to have_text("Editing #{batch_application.team_lead.name}'s Profile")

      fill_in_applicant_profile_form
      click_button 'Update Profile'

      expect(page).to have_text 'Complete'
      expect(page).to have_link 'Edit'
    end

    scenario 'user submits applicant profile reusing permanent address', js: true do
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'

      expect(page).to have_text("Editing #{batch_application.team_lead.name}'s Profile")

      fill_in_applicant_profile_form(skip_current_address: true)
      check 'Is your current address same as your permanent address?'

      # The current address input should disappear.
      expect(page).to_not have_selector('#application_stage_four_applicant_current_address', visible: true)

      click_button 'Update Profile'

      expect(page).to have_text 'Complete'
      expect(page).to have_link 'Edit'
      applicant = batch_application.team_lead.reload
      expect(applicant.current_address).to eq(applicant.permanent_address)
    end

    scenario 'form is submitted empty' do
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'
      click_button 'Update Profile'
      expect(page).to have_selector('.form-group.row.has-danger', count: 10)
    end

    context 'when editing applicant requiring income proof' do
      scenario 'user submits form with extra details' do
        visit apply_stage_path(stage_number: '6', update_profile: @applicant_requiring_income_proof.id)

        fill_in_applicant_profile_form

        attach_file 'Proof of Income', pdf_path
        attach_file 'Letter from Parent', image_path
        fill_in 'College Contact Number', with: '8976543210'

        click_button 'Update Profile'

        expect(page).to have_text 'Complete'
        expect(page).to have_link 'Edit'
      end

      scenario 'form is submitted empty' do
        visit apply_stage_path(stage_number: '6', update_profile: @applicant_requiring_income_proof.id)
        click_button 'Update Profile'
        expect(page).to have_selector('.form-group.row.has-danger', count: 13)
      end
    end
  end

  context 'when all applicants have added profile information' do
    let(:batch_application) { create :batch_application, :pre_selection_stage, application_round: application_round, team_size: 2 }

    before do
      address = [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")

      batch_application.batch_applicants.each do |applicant|
        applicant.update(
          fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE,
          role: Founder.valid_roles.sample,
          gender: Founder.valid_gender_values.sample,
          born_on: Date.parse('1990-01-01'),
          parent_name: Faker::Name.name,
          permanent_address: address,
          address_proof: File.open(image_path),
          current_address: address,
          phone: (9_876_543_000 + rand(999)).to_s,
          id_proof_type: BatchApplicant::ID_PROOF_TYPES.sample,
          id_proof_number: Faker::Internet.password,
          id_proof: File.open(image_path)
        )
      end

      sign_in_user(batch_application.team_lead.user, referer: apply_continue_path)
    end

    scenario 'partnership and education agreement PDFs are presented' do
      expect(page).to have_content('Your Partnership Deed is ready.')
      expect(page).to have_content('Your Agreement with SV.CO is ready.')
    end

    context 'when agreements have been verified' do
      let(:batch_application) { create :batch_application, :pre_selection_stage, application_round: application_round, team_size: 2, agreements_verified: true }

      scenario 'user submits payment details' do
        expect(page).to have_content('Your agreements have been verified by SV.CO as acceptable.')
        expect(page).to have_content('Transfer your total fee – ₹72,000')

        attach_file 'Partnership Deed', pdf_path
        fill_in 'Courier Name', with: 'DTDC'
        fill_in 'Courier Tracking Number', with: 'D1234567A'
        fill_in 'Payment Reference', with: 'HDFC123456'
        click_button 'Submit'

        expect(page).to have_text("We'll review them and get back to you as soon as we receive them.")
      end

      scenario 'user submits empty form' do
        click_button 'Submit'
        expect(page).to have_selector('.form-group.row.has-danger', count: 4)
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
          RoundStage.find_by(application_round: application_round, application_stage: stage_4).update!(ends_at: 1.day.ago)
          create(:batch_stage, application_round: application_round, application_stage: stage_5, starts_at: 3.days.ago)
        end

        scenario 'user is shown rejected state page'
      end
    end
  end
end
