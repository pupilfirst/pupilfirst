require 'rails_helper'

feature 'Certificate verification', js: true do
  include UserSpecHelper

  let(:issued_certificate) { create :issued_certificate }
  let!(:user) { issued_certificate.user }

  around do |example|
    Time.use_zone(user.time_zone) { example.run }
  end

  scenario 'user verifies certificate' do
    sign_in_user user, referrer: issued_certificate_path(serial_number: issued_certificate.serial_number)

    expect(page).to have_text(user.name)
    expect(page).to have_text(issued_certificate.certificate.course.name)
    expect(page).to have_text(issued_certificate.created_at.strftime('%b %-d, %Y'))
  end

  scenario 'a member of the public verifies the certificate' do
    visit issued_certificate_path(serial_number: issued_certificate.serial_number)

    expect(page).to have_text(user.name)
    expect(page).to have_text(issued_certificate.certificate.course.name)
    expect(page).to have_text(issued_certificate.created_at.strftime('%b %-d, %Y'))
  end

  context 'user is not present' do
    before do
      issued_certificate.update!(user_id: nil)
    end
    scenario 'a member of public verifies the certificate' do
      visit issued_certificate_path(serial_number: issued_certificate.serial_number)

      expect(page).to have_text(user.name)
      expect(page).to have_text(issued_certificate.certificate.course.name)
    end
  end
end
