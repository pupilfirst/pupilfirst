require 'rails_helper'

feature 'Certificates', js: true do
  include UserSpecHelper
  include NotificationHelper
  include RangeInputHelper

  # Setup a school with 2 school admins
  let(:school) { create :school, :current }
  let(:school_admin) { create :school_admin, school: school }
  let(:course) { create :course, school: school }

  let(:name) { Faker::Lorem.words(number: 3).join(' ') }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  scenario "a user who isn't signed in attempts to access the certificates interface" do
    visit certificates_school_course_path(course)
    expect(page).to have_text('Please sign in to continue.')
  end

  context 'when the user is a course author' do
    let!(:course_author) { create :course_author, course: course }

    scenario 'course author tries to access certificates interface' do
      sign_in_user course_author.user, referrer: certificates_school_course_path(course)
      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end

  scenario 'school admin uploads new certificates to the course' do
    sign_in_user school_admin.user, referrer: certificates_school_course_path(course)

    expect(page).to have_text("You haven't created any certificates yet!")

    click_button 'Create New Certificate'
    attach_file 'Certificate Base Image', File.absolute_path(Rails.root.join('spec/support/uploads/certificates/sample.png')), visible: false
    click_button 'Create Certificate'

    expect(page).to have_text("Done!")

    dismiss_notification

    expect(page).to have_text("Never issued")

    certificate = Certificate.last

    expect(certificate.name).to include(Time.zone.now.strftime("%-d %b %Y %-l"))
    expect(certificate.course).to eq(course)
    expect(certificate.image.attached?).to eq(true)
    expect(certificate.active).to eq(false)
    expect(certificate.qr_corner).to eq('Hidden')
    expect(certificate.qr_scale).to eq(100)
    expect(certificate.name_offset_top).to eq(45)
    expect(certificate.font_size).to eq(100)
    expect(certificate.margin).to eq(0)

    click_button 'Create New Certificate'
    fill_in 'Name', with: name
    attach_file 'Certificate Base Image', File.absolute_path(Rails.root.join('spec/support/uploads/certificates/sample.png')), visible: false
    click_button 'Create Certificate'
    dismiss_notification

    expect(Certificate.last.name).to eq(name)
  end

  context 'when there are existing certificates' do
    let(:certificate_issued) { create :certificate, :active, course: course }
    let!(:certificate_unissued) { create :certificate, course: course }

    before do
      2.times { create :issued_certificate, certificate: certificate_issued }
    end

    scenario 'school admin edits an unissued certificate' do
      sign_in_user school_admin.user, referrer: certificates_school_course_path(course)

      within("div[aria-label='Certificate #{certificate_issued.id}'") do
        expect(page).to have_text('Auto-issue')
        expect(page).to have_text('Issued 2 times')
      end

      within("div[aria-label='Certificate #{certificate_unissued.id}'") do
        expect(page).not_to have_text('Auto-issue')
        expect(page).to have_text('Never issued')
      end

      find("a[title='Edit Certificate #{certificate_unissued.name}'").click
      fill_in 'Name', with: name

      within('div[aria-label="auto_issue"]') do
        click_button 'Yes'
      end

      select_from_range self, 'margin', 10
      select_from_range self, 'name_offset_top', 50
      select_from_range self, 'font_size', 125

      within('div[aria-label="add_qr_code"]') do
        click_button 'Yes'
      end

      click_button 'Top Right'
      click_button 'Save Changes'

      expect(page).to have_text('Done!')

      dismiss_notification

      expect(certificate_unissued.reload.name).to eq(name)
      expect(certificate_unissued.margin).to eq(10)
      expect(certificate_unissued.name_offset_top).to eq(50)
      expect(certificate_unissued.font_size).to eq(125)
      expect(certificate_unissued.active).to eq(true)
      expect(certificate_issued.reload.active).to eq(false)

      find('button[title="Close"]').click

      within("div[aria-label='Certificate #{certificate_issued.id}'") do
        expect(page).not_to have_text('Auto-issue')
      end

      within("div[aria-label='Certificate #{certificate_unissued.id}'") do
        expect(page).to have_text('Auto-issue')
      end
    end

    scenario 'school admin edits an issued certificate' do
      sign_in_user school_admin.user, referrer: certificates_school_course_path(course)

      find("a[title='Edit Certificate #{certificate_issued.name}'").click
      fill_in 'Name', with: name

      expect(page).to have_text('This certificate has been issued 2 times.')
    end

    scenario 'school admin deletes an unissued certificate' do
      sign_in_user school_admin.user, referrer: certificates_school_course_path(course)

      expect(page).not_to have_selector("a[title='Delete Certificate #{certificate_issued.name}']")

      accept_confirm do
        find("a[title='Delete Certificate #{certificate_unissued.name}']").click
      end

      expect(page).to have_text('Done!')

      dismiss_notification

      expect(Certificate.count).to eq(1)
      expect(Certificate.first).to eq(certificate_issued)
    end
  end
end
