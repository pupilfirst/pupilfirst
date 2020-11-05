require 'rails_helper'

feature 'User Dashboard', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with founders and target for community.
  let(:school) { create :school, :current }

  # Course 1 - New Course
  let(:course_1) { create :course, school: school }
  let(:course_1_level_1) { create :level, :one, course: course_1 }
  let(:course_1_startup_1) { create :startup, level: course_1_level_1 }
  let(:founder) { create :founder, startup: course_1_startup_1, dashboard_toured: false }

  # Course 2 - Existing course
  let(:course_2) { create :course, school: school }
  let(:course_2_level_1) { create :level, :one, course: course_2 }
  let(:course_2_startup_1) { create :startup, level: course_2_level_1 }
  let!(:course_2_founder_1) { create :founder, startup: course_2_startup_1, user: founder.user, dashboard_toured: true }

  # Course 3 - Ended course
  let(:course_3) { create :course, school: school, ends_at: 1.day.ago }
  let(:course_3_level_1) { create :level, :one, course: course_3 }
  let(:course_3_startup_1) { create :startup, level: course_3_level_1 }
  let!(:course_3_founder_1) { create :founder, startup: course_3_startup_1, user: founder.user }

  # Course 4 - Founder Exited
  let(:course_4) { create :course, school: school }
  let(:course_4_level_1) { create :level, :one, course: course_4 }
  let(:course_4_startup_1) { create :team, level: course_4_level_1, dropped_out_at: 1.day.ago }
  let!(:course_4_founder_1) { create :founder, startup: course_4_startup_1, user: founder.user }

  # seed community
  let!(:community_1) { create :community, school: school, target_linkable: true }
  let!(:community_2) { create :community, school: school, target_linkable: true }
  let!(:community_3) { create :community, school: school, target_linkable: true }
  let!(:community_4) { create :community, school: school, target_linkable: true }

  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin, school: school }
  let(:course_author) { create :course_author, course: course_1 }

  before do
    create :faculty_course_enrollment, faculty: course_coach, course: course_1
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach, startup: course_2_founder_1.startup
    create :community_course_connection, course: course_1, community: community_1
    create :community_course_connection, course: course_2, community: community_2
    create :community_course_connection, course: course_3, community: community_3
    create :community_course_connection, course: course_4, community: community_4
  end

  scenario 'student visits the dashboard page' do
    sign_in_user(founder.user, referrer: dashboard_path)

    # A new course.
    within("div[aria-label=\"#{course_1.name}\"]") do
      expect(page).to have_text(course_1.name)
      expect(page).to have_text(course_1.description)
      expect(page).to have_link("View Course", href: curriculum_course_path(course_1))
    end

    # A course which is going on.
    within("div[aria-label=\"#{course_2.name}\"]") do
      expect(page).to have_text(course_2.name)
      expect(page).to have_text(course_2.description)
      expect(page).to have_link("View Course", href: curriculum_course_path(course_2))
    end

    # A course which has ended.
    within("div[aria-label=\"#{course_3.name}\"]") do
      expect(page).to have_text(course_3.name)
      expect(page).to have_text(course_3.description)
      expect(page).to have_link("View Curriculum", href: curriculum_course_path(course_3))
      expect(page).to have_text("Course Ended")
    end

    # Course from which student has dropped out.
    within("div[aria-label=\"#{course_4.name}\"]") do
      expect(page).to have_text(course_4.name)
      expect(page).to have_text(course_4.description)
      expect(page).to have_text("Dropped out")
      expect(page).not_to have_link("View Curriculum", href: curriculum_course_path(course_4))
    end

    click_button 'Communities'

    # Students should have access to communities which are linked to their courses,
    # regardless of whether the course is active...
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)

    # ...but not if they've dropped out from a course.
    expect(page).not_to have_text(community_4.name)

    # This student doesn't have any certificates, so the tab shouldn't be visible.
    expect(page).not_to have_button('Certificates')
  end

  scenario 'course coach visits dashboard page' do
    sign_in_user(course_coach.user, referrer: dashboard_path)

    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_1.description)
    expect(page).to have_link("View Curriculum", href: curriculum_course_path(course_1))
    expect(page).to have_link("Review Submissions", href: review_course_path(course_1))
    expect(page).to have_link("My Students", href: students_course_path(course_1))

    expect(page).not_to have_text(course_2.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    click_button 'Communities'

    # course_coach has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
    expect(page).to have_text(community_4.name)
  end

  scenario 'student coach visits dashboard page' do
    sign_in_user(team_coach.user, referrer: dashboard_path)

    expect(page).to have_text(course_2.name)
    expect(page).to have_text(course_2.description)
    expect(page).to have_link("View Curriculum", href: curriculum_course_path(course_2))
    expect(page).to have_link("Review Submissions", href: review_course_path(course_2))
    expect(page).to have_link("My Students", href: students_course_path(course_2))

    expect(page).not_to have_text(course_1.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    click_button 'Communities'

    # team_coach has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
    expect(page).to have_text(community_4.name)
  end

  scenario 'school admin visits dashboard page' do
    sign_in_user(school_admin.user, referrer: dashboard_path)

    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_2.name)
    expect(page).to have_text(course_3.name)
    expect(page).to have_text(course_4.name)

    # school admin can preview all courses in school
    expect(page).to have_link("View Course", href: curriculum_course_path(course_1))
    expect(page).to have_link("View Course", href: curriculum_course_path(course_2))
    expect(page).to have_link("View Course", href: curriculum_course_path(course_3))
    expect(page).to have_link("View Course", href: curriculum_course_path(course_4))

    click_button 'Communities'
    # school admin has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
    expect(page).to have_text(community_4.name)
  end

  scenario 'course author visits the dashboard page' do
    sign_in_user(course_author.user, referrer: dashboard_path)

    expect(page).to have_text(course_1.name)
    expect(page).not_to have_text(course_2.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    expect(page).to have_link("Edit Curriculum", href: curriculum_school_course_path(course_1))
    expect(page).to have_link("View Curriculum", href: curriculum_course_path(course_1))
  end

  context 'when the student has been issued some certificates' do
    let(:certificate_1) { create :certificate, course: course_1 }
    let(:certificate_2) { create :certificate, course: course_2 }
    let(:certificate_3) { create :certificate, course: course_2 }
    let!(:issued_certificate_1) { create :issued_certificate, certificate: certificate_1, user: founder.user }
    let!(:issued_certificate_2) { create :issued_certificate, certificate: certificate_2, user: founder.user }
    let!(:revoked_certificate) { create :issued_certificate, certificate: certificate_3, user: founder.user, revoker: school_admin.user, revoked_at: Time.zone.now }

    scenario 'student browses certificates on the dashboard page' do
      sign_in_user(founder.user, referrer: dashboard_path)

      # Switch to certificates tab and see if there are two links.
      click_button 'Certificates'
      expect(page).to have_link('View Certificate', href: "/c/#{issued_certificate_1.serial_number}")
      expect(page).to have_link('View Certificate', href: "/c/#{issued_certificate_2.serial_number}")
      expect(page).not_to have_link('View Certificate', href: "/c/#{revoked_certificate.serial_number}")
    end
  end

  context "when coach has a student profile that's dropped out" do
    let(:coach) { create :faculty, school: school, user: founder.user }

    before do
      create :faculty_course_enrollment, faculty: coach, course: course_4
    end

    scenario "dashboard doesn't show the dropped out warning for the course and shows relevant links" do
      sign_in_user(founder.user, referrer: dashboard_path)

      # Course from which student has dropped out.
      within("div[aria-label=\"#{course_4.name}\"]") do
        expect(page).to have_link("View Curriculum", href: curriculum_course_path(course_4))
        expect(page).to_not have_text("Your student profile for this course is locked, and cannot be updated")
      end
    end
  end
end
