require 'rails_helper'

feature 'User Home' do
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
  let(:course_4_startup_1) { create :startup, level: course_4_level_1 }
  let!(:course_4_founder_1) { create :founder, startup: course_4_startup_1, user: founder.user, exited: true }

  # seed community
  let!(:community_1) { create :community, school: school, target_linkable: true }
  let!(:community_2) { create :community, school: school, target_linkable: true }
  let!(:community_3) { create :community, school: school, target_linkable: true }

  let(:coach) { create :faculty, school: school }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course_1
    create :community_course_connection, course: course_1, community: community_1
    create :community_course_connection, course: course_2, community: community_2

    # Create a domain for school.
    create :domain, :primary, school: school
  end

  scenario 'When an active user visits he access courses and community', js: true do
    sign_in_user(founder.user, referer: home_path)

    # New Course
    within("div[aria-label=\"#{course_1.name}\"]") do
      expect(page).to have_text(course_1.name)
      expect(page).to have_text(course_1.description)
      expect(page).to have_link("Curriculum")
      expect(page).to have_link("Start Course")
    end

    # Existing Course
    within("div[aria-label=\"#{course_2.name}\"]") do
      expect(page).to have_text(course_2.name)
      expect(page).to have_text(course_2.description)
      expect(page).to have_link("Continue Course")
    end

    # Ended Course
    within("div[aria-label=\"#{course_3.name}\"]") do
      expect(page).to have_text(course_3.name)
      expect(page).to have_text(course_3.description)
      expect(page).to have_link("Course Ended")
    end

    # Founder profile archived
    within("div[aria-label=\"#{course_4.name}\"]") do
      expect(page).to have_text(course_4.name)
      expect(page).to have_text(course_4.description)
      expect(page).to have_text("Dropout out")
    end

    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).not_to have_text(community_3.name)
  end

  scenario 'When an faculty visits he access courses and community', js: true do
    sign_in_user(coach.user, referer: home_path)

    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_1.description)
    expect(page).to have_link("Review")
    expect(page).to have_link("Review Submissions")

    expect(page).not_to have_text(course_2.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    # Coach has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
  end
end
