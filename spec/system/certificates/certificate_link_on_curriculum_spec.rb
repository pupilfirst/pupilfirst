require 'rails_helper'

feature 'Certificate link on curriculum', js: true do
  include UserSpecHelper
  include SubmissionsHelper

  let(:school) { create :school, :current }
  let(:user) { create :user, school: school }
  let(:course) { create :course, school: school }
  let(:certificate) { create :certificate, :active, course: course }
  let!(:issued_certificate) { create :issued_certificate, certificate: certificate, user: user }
  let(:level_1) { create :level, :one, course: course }
  let(:team) { create :team, level: level_1 }
  let!(:student) { create :student, startup: team, user: user }
  let(:target_group) { create :target_group, level: level_1, milestone: true }
  let!(:target) { create :target, :with_markdown, :team, target_group: target_group }

  scenario 'user sees link to issued certificate on curriculum page' do
    sign_in_user user, referrer: curriculum_course_path(course)

    expect(page).to have_text('You have been issued a certificate')
    expect(page).to have_link('View Certificate', href: issued_certificate_path(serial_number: issued_certificate.serial_number))
  end

  context 'when the issued certificate has been revoked' do
    let(:school_admin) { create :school_admin }
    let!(:issued_certificate) { create :issued_certificate, certificate: certificate, user: user, revoker: school_admin.user, revoked_at: Time.zone.now }

    scenario 'user is now shown link to revoked certificate' do
      sign_in_user user, referrer: curriculum_course_path(course)

      expect(page).not_to have_text('You have been issued a certificate')
      expect(page).not_to have_link('View Certificate', href: issued_certificate_path(serial_number: issued_certificate.serial_number))
    end
  end
end
