require 'rails_helper'

def cohorts_path(course)
  "/school/courses/#{course.id}/cohorts?status=Active"
end

feature 'Cohorts Index', js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course }
  let!(:ended_cohort) { create :cohort, course: course, ends_at: 1.day.ago }

  let!(:school_admin) { create :school_admin, school: school }

  context 'with some students and coaches assigned to cohorts' do
    let!(:team_1) { create :team_with_students, cohort: live_cohort }
    let!(:team_2) { create :team_with_students, cohort: live_cohort }
    let!(:team_ended) { create :team_with_students, cohort: ended_cohort }
    let!(:coach_1) { create :faculty, school: school }
    let!(:coach_2) { create :faculty, school: school }

    before do
      create :faculty_cohort_enrollment, faculty: coach_1, cohort: live_cohort
      create :faculty_cohort_enrollment, faculty: coach_2, cohort: live_cohort
      create :faculty_cohort_enrollment, faculty: coach_1, cohort: ended_cohort
    end

    scenario 'School admin checkouts active cohorts' do
      sign_in_user school_admin.user, referrer: cohorts_path(course)

      expect(page).to have_text(live_cohort.name)
      expect(page).not_to have_text(ended_cohort.name)

      within("div[data-cohort-name='#{live_cohort.name}']") do
        expect(page).to have_content(live_cohort.description)
        expect(page).to have_content('Students')
        expect(page).to have_content(4)
        expect(page).to have_content('Coaches')
        expect(page).to have_content(2)
      end

      expect(page).to have_text('Only one cohort to show')

      expect(page).to have_link(
        'Add new cohort',
        href: "/school/courses/#{course.id}/cohorts/new"
      )
    end

    scenario 'School admin checkouts filters' do
      sign_in_user school_admin.user, referrer: cohorts_path(course)

      expect(page).to have_text(live_cohort.name)
      expect(page).not_to have_text(ended_cohort.name)

      expect(page).to have_text('Cohorts')

      fill_in 'Filter Resources', with: 'ended'
      click_button 'Pick Status: Ended'

      within("div[data-cohort-name='#{ended_cohort.name}']") do
        expect(page).to have_content(ended_cohort.description)
        expect(page).to have_content('Students')
        expect(page).to have_content(2)
        expect(page).to have_content('Coaches')
        expect(page).to have_content(1)
      end

      expect(page).not_to have_text(live_cohort.name)

      click_button 'Remove selection: Ended'

      expect(page).to have_text(live_cohort.name)
      expect(page).to have_text(ended_cohort.name)
    end
  end

  context 'when there are a large number of cohorts' do
    let!(:cohorts) do
      create_list :cohort, 30, course: course, ends_at: 10.days.from_now
    end

    let(:oldest_created) { cohorts[-1] }
    let(:newest_created) { cohorts[-2] }
    let(:first_ending) { cohorts[-3] }
    let(:cohort_aaa) { cohorts[-4] }
    let(:cohort_zzz) { cohorts[-5] }

    before do
      cohort_aaa.update!(name: 'AA aa')
      cohort_zzz.update!(name: 'ZZ zz')
      oldest_created.update!(created_at: Time.at(0))
      newest_created.update!(created_at: 1.day.from_now)
      first_ending.update!(ends_at: 1.day.from_now)
    end

    scenario 'school admin can order cohorts' do
      sign_in_user school_admin.user, referrer: cohorts_path(course)

      expect(page).to have_content('Showing 20 of 31 cohorts')

      # Check ordering by last created
      expect(find('.cohorts-container:first-child')).to have_text(
        newest_created.name
      )

      click_button('Load More')

      expect(find('.cohorts-container:last-child')).to have_text(
        oldest_created.name
      )

      # Reverse sorting
      click_button 'Order by Last Created'
      click_button 'Order by First Created'

      expect(find('.cohorts-container:first-child')).to have_text(
        oldest_created.name
      )

      click_button('Load More')

      expect(find('.cohorts-container:last-child')).to have_text(
        newest_created.name
      )

      # Check ordering by last updated
      click_button 'Order by First Created'
      click_button 'Order by Last Ending'

      # Cohort without an end date will be listed first
      expect(find('.cohorts-container:first-child')).to have_text(
        live_cohort.name
      )

      click_button('Load More')

      expect(find('.cohorts-container:last-child')).to have_text(
        first_ending.name
      )

      # Check ordering by name
      click_button 'Order by Last Ending'
      click_button 'Order by Name'

      expect(find('.cohorts-container:first-child')).to have_text(
        cohort_aaa.name
      )

      click_button('Load More')

      expect(find('.cohorts-container:last-child')).to have_text(
        cohort_zzz.name
      )
    end

    scenario 'school admin can filter cohorts' do
      sign_in_user school_admin.user, referrer: cohorts_path(course)

      expect(page).to have_content('Showing 20 of 31 cohorts')
      click_button 'Order by Last Created'
      click_button 'Order by Name'

      expect(page).not_to have_text(cohort_zzz.name)

      fill_in 'Filter Resources', with: 'ZZ'
      click_button 'Pick Search by Name: ZZ'

      expect(page).to have_text(cohort_zzz.name)
    end
  end
end
