require 'rails_helper'

feature 'Pre-selection Stage' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:team_lead) { startup.admin }
  let(:founder_1) { create :founder, startup: startup }
  let(:founder_2) { create :founder, startup: startup }
  let(:current_founder) { [team_lead, founder_1, founder_2].sample }
  let(:level_0) { create :level, :zero }
  let!(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }
  let!(:submit_coding_task_target) { create :target, role: Target::ROLE_TEAM, target_group: level_0_targets }
  let!(:submit_video_task_target) { create :target, role: Target::ROLE_TEAM, target_group: level_0_targets }
  let!(:attend_interview_target) { create :target, :admissions_attend_interview, target_group: level_0_targets }
  let!(:preselection_target) { create :target, :admissions_pre_selection, target_group: level_0_targets }
  let!(:application_fee_payment) { create :payment, :paid, founder: current_founder, startup: startup }
  let(:image_path) { File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg')) }
  let(:pdf_path) { File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }
  let!(:tet_joined) { create :tet_joined }
  let!(:l1_milestones) { create :target_group, level: level_1, milestone: true }
  let!(:level_1) { create :level, :one }

  context "when founder hasn't completed prerequisites" do
    scenario 'founder is blocked from accessing preselection page' do
      sign_in_user(team_lead.user, referer: admissions_preselection_path)

      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  context 'when the founder has completed prerequisites' do
    before do
      attend_interview_target.prerequisite_targets << [submit_coding_task_target, submit_video_task_target]
      complete_target team_lead, screening_target
      complete_target team_lead, fee_payment_target
      complete_target team_lead, cofounder_addition_target
      complete_target team_lead, submit_coding_task_target
      complete_target team_lead, submit_video_task_target
      complete_target team_lead, attend_interview_target
      team_lead.update(fee_payment_method: Founder::PAYMENT_METHOD_MERIT_SCHOLARSHIP)
      founder_1.update(fee_payment_method: Founder::PAYMENT_METHOD_REGULAR_FEE)
      founder_2.update(fee_payment_method: Founder::PAYMENT_METHOD_MERIT_SCHOLARSHIP)
    end

    scenario 'when the founder visits the preselection page' do
      sign_in_user(current_founder.user, referer: admissions_preselection_path)
      expect(page).to have_content('Your Startup awaits!')
      expect(page).to have_content('This is the first step on an exciting journey that will help you build a startup')
      expect(page).to have_content('Fee Payment Status')
      expect(page).to have_content('Payment Instructions')
    end

    scenario 'when two founders have scholarships and another founder receives the 3000 rupee refund', js: true do
      sign_in_user(current_founder.user, referer: admissions_preselection_path)
      click_on 'Payment Instructions'
      expect(page).to have_content('Transfer your total fee – ₹47,000')
    end

    def fill_in_founder_profile_form(skip_current_address: false)
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

    scenario 'user submits founder profiles' do
      sign_in_user(current_founder.user, referer: admissions_preselection_path)
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'

      first_founder = startup.founders.order('name ASC').first
      expect(page).to have_text("Editing #{first_founder.name}'s Profile")

      fill_in_founder_profile_form
      click_button 'Update Profile'

      expect(page).to have_text 'Complete'
      expect(page).to have_link 'Edit'
    end

    scenario 'user submits applicant profile reusing permanent address', js: true do
      sign_in_user(current_founder.user, referer: admissions_preselection_path)
      page.find('table.payment-status-table tbody tr', match: :first).click_link 'Update profile'

      first_founder = startup.founders.order('name ASC').first
      expect(page).to have_text("Editing #{first_founder.name}'s Profile")

      fill_in_founder_profile_form(skip_current_address: true)
      check 'Is your current address same as your permanent address?'

      # The current address input should disappear.
      expect(page).to_not have_selector('#admissions_preselection_stage_applicant_communication_address', visible: true)

      click_button 'Update Profile'

      expect(page).to have_text 'Complete'
      expect(page).to have_link 'Edit'
      founder = team_lead.reload
      expect(founder.communication_address).to eq(founder.permanent_address)
    end

    scenario 'user submits founder profile with hardship scholarship' do
      founder_2.update(fee_payment_method: Founder::PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP)
      founder_2.reload

      sign_in_user(current_founder.user, referer: admissions_preselection_path(update_profile: founder_2.id))

      fill_in_founder_profile_form

      attach_file 'Proof of Income', pdf_path
      attach_file 'Letter from Parent', image_path
      fill_in 'College Contact Number', with: '8976543210'

      click_button 'Update Profile'

      expect(page).to have_text 'Complete'
      expect(page).to have_link 'Edit'
    end

    context 'when the founder edit form is submitted empty' do
      before do
        first_founder = startup.founders.order('name ASC').first
        first_founder.update(fee_payment_method: Founder::PAYMENT_METHOD_REGULAR_FEE)

        second_founder = startup.founders.order('name ASC').second
        second_founder.update(fee_payment_method: Founder::PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP)
      end

      scenario 'form submitted empty for founder paying regular fee' do
        sign_in_user(current_founder.user, referer: admissions_preselection_path)
        page.all('table.payment-status-table tbody tr')[0].click_link 'Update profile'
        click_button 'Update Profile'

        expect(page).to have_selector('.form-group.row.has-danger', count: 9)
      end

      scenario 'form submitted empty for founder requiring proofs for hardship scholarship' do
        sign_in_user(current_founder.user, referer: admissions_preselection_path)
        page.all('table.payment-status-table tbody tr')[1].click_link 'Update profile'
        click_button 'Update Profile'

        expect(page).to have_selector('.form-group.row.has-danger', count: 12)
      end
    end

    scenario 'when profiles of all founders are complete' do
      sign_in_user(current_founder.user, referer: admissions_preselection_path)
      page.all('table.payment-status-table tbody tr')[0].click_link 'Update profile'
      fill_in_founder_profile_form
      click_button 'Update Profile'

      page.all('table.payment-status-table tbody tr')[1].click_link 'Update profile'
      fill_in_founder_profile_form
      click_button 'Update Profile'

      page.all('table.payment-status-table tbody tr')[2].click_link 'Update profile'
      fill_in_founder_profile_form
      click_button 'Update Profile'

      expect(page).to have_content('Your Partnership Deed is ready.')
      expect(page).to have_content('Your Agreement with SV.CO is ready.')
    end

    context 'when agreements have been verified' do
      let!(:tet_team_update) { create :timeline_event_type, :team_update }

      before do
        startup.update(agreements_verified: true)
      end

      def fill_in_submission_form
        attach_file 'Partnership Deed', pdf_path
        fill_in 'Courier Name', with: 'DTDC'
        fill_in 'Courier Tracking Number', with: 'D1234567A'
        fill_in 'Payment Reference', with: 'HDFC123456'
      end

      scenario 'when user submits payment details' do
        sign_in_user(current_founder.user, referer: admissions_preselection_path)
        expect(page).to have_content('Your agreements have been verified by SV.CO as acceptable.')
        expect(page).to have_content('Transfer your total fee – ₹47,000')

        fill_in_submission_form
        click_button 'Submit'

        expect(page).to have_selector('.founder-dashboard-header__product-title')
        expect(TimelineEvent.last.target.key).to eq(Target::KEY_ADMISSIONS_PRE_SELECTION)
      end

      scenario 'user submits empty form' do
        sign_in_user(current_founder.user, referer: admissions_preselection_path)
        click_button 'Submit'
        expect(page).to have_selector('.form-group.row.has-danger', count: 4)
      end

      scenario 'when preselection submission is verified', js: true do
        sign_in_user(current_founder.user, referer: admissions_preselection_path)

        fill_in_submission_form
        click_button 'Submit'

        TimelineEvent.last.update(status: TimelineEvent::STATUS_VERIFIED)

        visit dashboard_founder_path

        expect(page).to have_content('You have successfully completed the first step in your startup journey. We are proud to have you join our collective.')

        click_button 'Level Up'

        expect(page).to have_content(l1_milestones.name)
        expect(page).to have_content(l1_milestones.description)

        # Also ensure the Page path is correct (analytics requirement).
        expect(page).to have_current_path(dashboard_founder_path(from: 'level_up', from_level: 0))
      end
    end
  end
end
