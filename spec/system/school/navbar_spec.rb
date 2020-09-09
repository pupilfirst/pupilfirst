require 'rails_helper'

feature 'School Admin Navbar', js: true do
  include UserSpecHelper

  let(:school_1) { create :school, :current }
  let(:school_2) { create :school }
  let(:school_admin) { create :school_admin, school: school_1 }

  # Let there be two courses in 'this 'school.
  let!(:course_1) { create :course, school: school_1 }
  let!(:course_2) { create :course, school: school_1 }

  # And another in a different school.
  let!(:course_3) { create :course, school: school_2 }

  scenario 'school admin visits the admin interface' do
    sign_in_user school_admin.user, referrer: school_path

    # User should be on the school admin overview page.
    expect(current_path).to eq('/school')

    # There should be additional links on the navbar.
    expect(page).to have_link('Coaches', href: '/school/coaches')
    expect(page).to have_link('Settings', href: '/school/customize')
    expect(page).to have_link('Courses', href: '/school/courses')
    expect(page).to have_link('Communities', href: '/school/communities')

    # Links to the student page for all courses in school should also be there.
    expect(page).to have_link(course_1.name, href: "/school/courses/#{course_1.id}/students")
    expect(page).to have_link(course_2.name, href: "/school/courses/#{course_2.id}/students")

    # Courses from other schools should not be listed.
    expect(page).not_to have_link(course_3.name)

    # There should also be a link to Sign Out
    expect(page).to have_link('Sign Out')

    # Check out the settings submenu.
    click_link('Settings')
    expect(page).to have_link('Customization', href: "/school/customize")

    # Check out the course submenu.
    find('a[title="Overview"]').click
    click_link(course_1.name)
    expect(page).to have_link('Students', href: "/school/courses/#{course_1.id}/students")
    expect(page).to have_link('Coaches', href: "/school/courses/#{course_1.id}/coaches")
    expect(page).to have_link('Curriculum', href: "/school/courses/#{course_1.id}/curriculum")

    # Use the dropdown to navigate to the second course.
    click_button course_1.name
    click_link course_2.name

    expect(page).to have_link('Curriculum', href: "/school/courses/#{course_2.id}/curriculum")

    # Navbar should also include links to dashboard page
    expect(page).to have_link('Dashboard', href: "/dashboard")
  end
end
