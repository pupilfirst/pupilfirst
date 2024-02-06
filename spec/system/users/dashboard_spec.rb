require "rails_helper"

feature "User Dashboard", js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with students and target for community.
  let(:school) { create :school, :current }

  # Course 1 - New Course
  let(:course_1) { create :course, school: school }
  let(:course_1_cohort) { create :cohort, course: course_1 }
  let(:course_1_level_1) { create :level, :one, course: course_1 }
  let(:student) { create :student, cohort: course_1_cohort }

  # Course 2 - Existing course
  let(:course_2) { create :course, school: school }
  let(:course_2_cohort) { create :cohort, course: course_2 }
  let(:course_2_level_1) { create :level, :one, course: course_2 }
  let!(:course_2_student_1) do
    create :student, cohort: course_2_cohort, user: student.user
  end

  # Course 3 - Ended course
  let(:course_3) { create :course, school: school }
  let(:course_3_cohort) { create :cohort, course: course_3, ends_at: 1.day.ago }
  let(:course_3_level_1) { create :level, :one, course: course_3 }
  let!(:course_3_student_1) do
    create :student, user: student.user, cohort: course_3_cohort
  end
  let!(:course_3_student_profile_for_admin) do
    create :student, user: school_admin.user, cohort: course_3_cohort
  end

  # Course 4 - Student Exited
  let(:course_4) { create :course, school: school }
  let(:course_4_cohort) { create :cohort, course: course_4 }
  let(:course_4_level_1) { create :level, :one, course: course_4 }
  let!(:course_4_student_1) do
    create :student,
           user: student.user,
           cohort: course_4_cohort,
           dropped_out_at: 1.day.ago
  end

  # Course 5 - Access Ended
  let(:course_5) { create :course, school: school }
  let(:course_5_cohort_ended) do
    create :cohort, course: course_5, ends_at: 1.day.ago
  end
  let!(:course_5_cohort_active) { create :cohort, course: course_5 }
  let(:course_5_level_1) { create :level, :one, course: course_5 }
  let!(:course_5_student_1) do
    create :student, user: student.user, cohort: course_5_cohort_ended
  end

  # Course 6 - Access end date set to a future date
  let(:course_6) { create :course, school: school }
  let(:course_6_cohort) do
    create :cohort, course: course_6, ends_at: 1.day.from_now
  end
  let(:course_6_level_1) { create :level, :one, course: course_6 }

  let!(:course_6_student_1) do
    create :student, user: student.user, cohort: course_6_cohort
  end

  # Course Archived
  let(:course_archived) do
    create :course, school: school, archived_at: 1.day.ago
  end
  let(:course_archived_cohort) do
    create :cohort, course: course_archived, ends_at: 1.day.ago
  end
  let(:course_archived_level_1) { create :level, :one, course: course_archived }
  let(:course_archived_team_1) { create :team, dropped_out_at: 1.day.ago }
  let!(:course_archived_student_1) do
    create :student, user: student.user, cohort: course_archived_cohort
  end
  let!(:course_archived_student_2) do
    create :student, cohort: course_archived_cohort
  end
  let!(:course_archived_student_profile_for_admin) do
    create :student, user: school_admin.user, cohort: course_archived_cohort
  end

  # Course Ended - For Admin
  let!(:course_ended) { create :course, school: school }
  let!(:course_ended_cohort) do
    create :cohort, course: course_ended, ends_at: 1.day.ago
  end

  # seed community
  let!(:community_1) do
    create :community, school: school, target_linkable: true
  end
  let!(:community_2) do
    create :community, school: school, target_linkable: true
  end
  let!(:community_3) do
    create :community, school: school, target_linkable: true
  end
  let!(:community_4) do
    create :community, school: school, target_linkable: true
  end

  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin, school: school }
  let(:course_author) { create :course_author, course: course_1 }

  before do
    create :faculty_cohort_enrollment,
           faculty: course_coach,
           cohort: course_1_cohort
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: team_coach,
           student: course_2_student_1
    create :community_course_connection,
           course: course_1,
           community: community_1
    create :community_course_connection,
           course: course_2,
           community: community_2
    create :community_course_connection,
           course: course_3,
           community: community_3
    create :community_course_connection,
           course: course_4,
           community: community_4
    create :community_course_connection,
           course: course_archived,
           community: community_4
  end

  scenario "student visits the dashboard page" do
    sign_in_user(student.user, referrer: dashboard_path)

    # A new course.
    within("div[aria-label=\"#{course_1.name}\"]") do
      expect(page).to have_text(course_1.name)
      expect(page).to have_text(course_1.description)
      expect(page).to have_link(
        "View Course",
        href: curriculum_course_path(course_1)
      )
    end

    # A course which is going on.
    within("div[aria-label=\"#{course_2.name}\"]") do
      expect(page).to have_text(course_2.name)
      expect(page).to have_text(course_2.description)
      expect(page).to have_link(
        "View Course",
        href: curriculum_course_path(course_2)
      )
    end

    # A course which has ended.
    within("div[aria-label=\"#{course_3.name}\"]") do
      expect(page).to have_text(course_3.name)
      expect(page).to have_text(course_3.description)
      expect(page).to have_link(
        "View Curriculum",
        href: curriculum_course_path(course_3)
      )
      expect(page).to have_text("Course Ended")
    end

    # Course from which student has dropped out.
    within("div[aria-label=\"#{course_4.name}\"]") do
      expect(page).to have_text(course_4.name)
      expect(page).to have_text(course_4.description)
      expect(page).to have_text("Dropped out")
      expect(page).not_to have_link(
        "View Curriculum",
        href: curriculum_course_path(course_4)
      )
    end

    # Course where student's access has ended.
    within("div[aria-label=\"#{course_5.name}\"]") do
      expect(page).to have_text(course_5.name)
      expect(page).to have_text(course_5.description)
      expect(page).to have_text("Preview/Limited Access")
      expect(page).to have_link(
        "View Curriculum",
        href: curriculum_course_path(course_5)
      )
    end

    # Course where student's course access end date is set to a future date.
    within("div[aria-label=\"#{course_6.name}\"]") do
      expect(page).to have_text(course_6.name)
      expect(page).to have_text(course_6.description)
      expect(page).to_not have_text("Preview/Limited Access")
      expect(page).to have_link(
        "View Course",
        href: curriculum_course_path(course_6)
      )
    end

    # Course that has been archived.
    expect(page).not_to have_text(course_archived.name)

    click_button "Communities"

    # Students should have access to communities which are linked to their courses,
    # regardless of whether the course is active...
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)

    # ...but not if they've dropped out from a course.
    expect(page).not_to have_text(community_4.name)

    # This student doesn't have any certificates, so the tab shouldn't be visible.
    expect(page).not_to have_button("Certificates")
  end

  scenario "course coach visits dashboard page" do
    sign_in_user(course_coach.user, referrer: dashboard_path)

    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_1.description)
    expect(page).to have_link(
      "View Curriculum",
      href: curriculum_course_path(course_1)
    )
    expect(page).to have_link(
      "Review Submissions",
      href: review_course_path(course_1)
    )
    expect(page).to have_link("My Cohorts", href: cohorts_course_path(course_1))

    expect(page).not_to have_text(course_2.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    click_button "Communities"

    # course_coach has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
    expect(page).to have_text(community_4.name)
  end

  scenario "student coach visits dashboard page" do
    sign_in_user(team_coach.user, referrer: dashboard_path)

    expect(page).to have_text(course_2.name)
    expect(page).to have_text(course_2.description)
    expect(page).to have_link(
      "View Curriculum",
      href: curriculum_course_path(course_2)
    )
    expect(page).to have_link(
      "Review Submissions",
      href: review_course_path(course_2)
    )
    expect(page).to have_link("My Cohorts", href: cohorts_course_path(course_2))

    expect(page).not_to have_text(course_1.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    click_button "Communities"

    # team_coach has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
    expect(page).to have_text(community_4.name)
  end

  scenario "school admin visits dashboard page" do
    sign_in_user(school_admin.user, referrer: dashboard_path)

    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_2.name)
    expect(page).to have_text(course_3.name)
    expect(page).to have_text(course_4.name)

    # school admin can preview all courses in school
    expect(page).to have_link(
      "View Course",
      href: curriculum_course_path(course_1)
    )
    expect(page).to have_link(
      "View Course",
      href: curriculum_course_path(course_2)
    )

    # ended course with a student profile will be listed on the dashboard
    expect(page).to have_link(
      "View Course",
      href: curriculum_course_path(course_3)
    )
    expect(page).to have_link(
      "View Course",
      href: curriculum_course_path(course_4)
    )

    # ended and archived courses will be hidden
    expect(page).not_to have_text(course_archived.name)
    expect(page).not_to have_text(course_ended.name)

    click_button "Communities"

    # school admin has access to all communities in school
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)
    expect(page).to have_text(community_3.name)
    expect(page).to have_text(community_4.name)
  end

  scenario "course author visits the dashboard page" do
    sign_in_user(course_author.user, referrer: dashboard_path)

    expect(page).to have_text(course_1.name)
    expect(page).not_to have_text(course_2.name)
    expect(page).not_to have_text(course_3.name)
    expect(page).not_to have_text(course_4.name)

    expect(page).to have_link(
      "Edit Curriculum",
      href: curriculum_school_course_path(course_1)
    )
    expect(page).to have_link(
      "View Curriculum",
      href: curriculum_course_path(course_1)
    )
  end

  context "when the student has been issued some certificates" do
    let(:certificate_1) { create :certificate, course: course_1 }
    let(:certificate_2) { create :certificate, course: course_2 }
    let(:certificate_3) { create :certificate, course: course_2 }
    let!(:issued_certificate_1) do
      create :issued_certificate, certificate: certificate_1, user: student.user
    end
    let!(:issued_certificate_2) do
      create :issued_certificate, certificate: certificate_2, user: student.user
    end
    let!(:revoked_certificate) do
      create :issued_certificate,
             certificate: certificate_3,
             user: student.user,
             revoker: school_admin.user,
             revoked_at: Time.zone.now
    end

    scenario "student browses certificates on the dashboard page" do
      sign_in_user(student.user, referrer: dashboard_path)

      # Switch to certificates tab and see if there are two links.
      click_button "Certificates"
      expect(page).to have_link(
        "View Certificate",
        href: "/c/#{issued_certificate_1.serial_number}"
      )
      expect(page).to have_link(
        "View Certificate",
        href: "/c/#{issued_certificate_2.serial_number}"
      )
      expect(page).not_to have_link(
        "View Certificate",
        href: "/c/#{revoked_certificate.serial_number}"
      )
    end
  end

  context "when coach has a student profile that's dropped out" do
    let(:coach) { create :faculty, school: school, user: student.user }

    before do
      create :faculty_cohort_enrollment,
             faculty: coach,
             cohort: course_4.cohorts.first
    end

    scenario "dashboard doesn't show the dropped out warning for the course and shows relevant links" do
      sign_in_user(student.user, referrer: dashboard_path)

      # Course from which student has dropped out.
      within("div[aria-label=\"#{course_4.name}\"]") do
        expect(page).to have_link(
          "View Curriculum",
          href: curriculum_course_path(course_4)
        )
        expect(page).to_not have_text(
          "Your student profile for this course is locked, and cannot be updated"
        )
      end
    end
  end

  scenario "dashboard hides archived courses and linked resources" do
    sign_in_user(course_archived_student_2.user, referrer: dashboard_path)

    expect(page).not_to have_text(course_archived.name)
    expect(page).not_to have_text("community")
    expect(page).to have_text("You don't have any active courses right now.")
  end

  scenario "dashboard hides standing shield when school has standing disabled" do
    sign_in_user(student.user, referrer: dashboard_path)

    expect(page).not_to have_text("View Standing")
  end

  context "when school has standing enabled" do
    let!(:standing_1) { create :standing, default: true }
    before do
      # Enable standings in the school configuration
      school.update!(configuration: { enable_standing: true })
    end

    scenario "dashboard shows standing information" do
      sign_in_user(student.user, referrer: dashboard_path)

      expect(page).to have_text(standing_1.name)

      expect(page).to have_text("View Standing")

      click_link "View Standing"

      expect(page).to have_current_path(standing_user_path())
    end
  end
end
