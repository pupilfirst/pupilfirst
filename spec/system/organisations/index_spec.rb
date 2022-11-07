require 'rails_helper'

feature 'Organisation index' do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:another_school) { create :school }

  let!(:organisation_1) { create :organisation, school: school }
  let!(:organisation_2) { create :organisation, school: school }

  let!(:organisation_in_another_school) do
    create :organisation, school: another_school
  end

  let(:school_admin_user) { create :user, school: school }

  let!(:school_admin) do
    create :school_admin, school: school, user: school_admin_user
  end

  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin,
           organisation: organisation_1,
           user: org_admin_user
  end

  let(:regular_user) { create :user, school: school }

  context 'when the user is a school admin' do
    scenario 'user can see all organisations in the school' do
      sign_in_user(school_admin_user, referrer: organisations_path)

      expect(page).to have_link(
        organisation_1.name,
        href: organisation_path(organisation_1)
      )

      expect(page).to have_link(
        organisation_2.name,
        href: organisation_path(organisation_2)
      )

      expect(page).not_to have_link(organisation_in_another_school.name)
    end
  end

  context 'when the user is an organisation admin in one school' do
    scenario 'user gets redirected to org page' do
      sign_in_user(org_admin_user, referrer: organisations_path)

      expect(page).to have_current_path(organisation_path(organisation_1))
    end
  end

  context 'when the user is an organisation admin in multiple schools' do
    let!(:org_admin_2) do
      create :organisation_admin,
             organisation: organisation_2,
             user: org_admin_user
    end

    scenario 'user is shown the organisations index page' do
      sign_in_user(org_admin_user, referrer: organisations_path)

      expect(page).to have_link(organisation_1.name)
      expect(page).to have_link(organisation_2.name)
    end
  end

  context 'when the user is a non-admin' do
    scenario 'user cannot see the organisations index page' do
      sign_in_user(regular_user, referrer: organisations_path)

      expect(page).to have_http_status(:not_found)
    end
  end
end
