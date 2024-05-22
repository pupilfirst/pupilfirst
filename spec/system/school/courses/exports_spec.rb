require "rails_helper"

feature "Course Exports", js: true do
  include UserSpecHelper
  include NotificationHelper
  include HtmlSanitizerSpecHelper

  let(:level) { create :level }
  let(:cohort) { create :cohort, course: level.course }

  let(:team_1) { create :team, cohort: cohort }
  let(:team_2) { create :team, cohort: cohort }
  let(:student_1) do
    create :student, cohort: cohort, team: team_1, tag_list: ["tag 1", "tag 2"]
  end
  let(:student_2) do
    create :student, cohort: cohort, team: team_2, tag_list: ["tag 3"]
  end
  let(:school) { student_1.school }
  let(:course) { student_1.course }
  let!(:school_admin) { create :school_admin, school: school }
  let(:target_group) { create :target_group, level: level }
  let!(:target) { create :target, target_group: target_group }

  let!(:standing_1) { create :standing, school: school, default: true }
  let!(:standing_2) { create :standing, school: school }

  let!(:user_standing_1) do
    create(
      :user_standing,
      user: student_1.user,
      standing: standing_1,
      creator: school_admin.user,
      reason: "Reason 1",
      created_at: 4.days.ago
    )
  end

  let!(:user_standing_2) do
    create(
      :user_standing,
      user: student_1.user,
      standing: standing_2,
      creator: school_admin.user,
      reason: "Reason 2",
      created_at: 3.days.ago
    )
  end

  let!(:user_standing_3) do
    create(
      :user_standing,
      user: student_1.user,
      standing: standing_2,
      creator: school_admin.user,
      reason: "Reason 3",
      created_at: 3.days.ago,
      archived_at: 2.days.ago
    )
  end

  before do
    # Add those tags to school's list of team tags.
    school.student_tag_list.add("tag 1", "tag 2", "tag 3")
    school.save!

    school.configuration = school.configuration.merge("enable_standing" => true)
    school.save!
  end

  scenario "school admin creates a students export" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    expect(page).to have_text("You haven't exported anything yet!")

    find("h5", text: "Create New Export").click

    click_button("Create Export")

    # The user should be notified.
    expect(page).to have_text("Your export is being processed")

    dismiss_notification

    # The Course report should be accurate.
    export = CourseExport.last
    expect(export.user).to eq(school_admin.user)
    expect(export.course).to eq(course)
    expect(export.tag_list).to be_empty
    expect(export.reviewed_only).to eq(false)
    expect(export.include_user_standings).to eq(false)

    # The empty list message should have disappeared.
    expect(page).not_to have_text("You haven't exported anything yet!")

    # There should be a course export entry saying it was requested just now.
    expect(page).to have_text("Requested less than a minute ago")

    # A mail should be sent to requesting user when the report is prepared.
    open_email(school_admin.user.email)
    expect(current_email.subject).to have_text(
      "Export of #{course.name} course is ready for download"
    )
    expect(sanitize_html(current_email.body)).to have_text(
      exports_school_course_path(course)
    )

    # The export file should be attached at this point.
    expect(export.reload.file.attached?).to eq(true)

    # Reload the page - it should say the report has been prepared.
    visit current_path
    expect(page).to have_text("Prepared less than a minute ago")
    expect(page).to have_link(
      nil,
      href:
        Rails.application.routes.url_helpers.rails_blob_path(
          export.file,
          only_path: true
        )
    )
  end

  scenario "school admin creates a teams export" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    expect(page).to have_text("You haven't exported anything yet!")

    find("h5", text: "Create New Export").click

    click_button("Teams")
    click_button("Only targets with reviewed assignment")
    click_button("Create Export")

    expect(page).to have_text("Your export is being processed")

    export = CourseExport.last

    within("div[aria-label='Export #{export.id}'") do
      expect(page).to have_text("Teams")
      expect(page).to have_text("Reviewed Submissions Only")
    end
  end

  scenario "school admin creates a students export for specific tags" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    find("h5", text: "Create New Export").click
    find('button[title="Select tag 1"]').click
    find('button[title="Select tag 2"]').click

    # Tag 3 should also be listed. Let's not pick it, though.
    expect(page).to have_selector('button[title="Select tag 3"]')

    click_button("Create Export")

    expect(page).to have_text("Your export is being processed")

    # The Course report should be accurate.
    export = CourseExport.last
    expect(export.tag_list).to contain_exactly("tag 1", "tag 2")

    expect(page).to have_text("tag 1")
    expect(page).to have_text("tag 2")
  end

  scenario "school admin creates a teams export for specific tags" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    find("h5", text: "Create New Export").click
    click_button("Teams")
    find('button[title="Select tag 1"]').click
    click_button("Create Export")

    expect(page).to have_text("Your export is being processed")
    expect(CourseExport.last.tag_list).to contain_exactly("tag 1")
    expect(page).to have_text("tag 1")
  end

  scenario "school admin creates a student export with only reviewed submissions" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    find("h5", text: "Create New Export").click
    click_button("Only targets with reviewed assignment")

    click_button("Create Export")

    expect(page).to have_text("Your export is being processed")

    # The Course report should be accurate.
    export = CourseExport.last
    expect(export.reviewed_only).to eq(true)

    expect(page).to have_text("Reviewed Submissions Only")
  end

  scenario "school admin creates a student export with including inactive students" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    find("h5", text: "Create New Export").click
    click_button("All Students")

    click_button("Create Export")

    expect(page).to have_text("Your export is being processed")

    # The Course report should be accurate.
    export = CourseExport.last
    expect(export.include_inactive_students).to eq(true)

    expect(page).to have_text("Included Inactive Students")
  end

  scenario "school admin creates a student export with user standings" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    find("h5", text: "Create New Export").click
    find(".toggle-button__group .toggle-button__button", text: "Yes").click

    click_button("Create Export")

    expect(page).to have_text("Your export is being processed")

    export = CourseExport.last
    expect(export.include_user_standings).to eq(true)
    expect(page).to have_text("Includes user standings")
  end

  scenario "include user standings option is hidden when export type is not students" do
    sign_in_user school_admin.user, referrer: exports_school_course_path(course)

    find("h5", text: "Create New Export").click
    click_button("Teams")

    expect(page).not_to have_selector(".toggle-button__group")
  end

  context "with many exports" do
    before do
      14.times { create :course_export, :students, course_id: course.id }
    end

    scenario "school admin paginates through the course export page" do
      sign_in_user school_admin.user,
                   referrer: exports_school_course_path(course)
      # check if the pagination is working
      expect(page).to have_link(
        "2",
        href: "/school/courses/#{course.id}/exports?page=2"
      )
      expect(page).to have_selector(".course-faculty__list-item", count: 10)
      click_link "2"
      expect(page).to have_selector(".course-faculty__list-item", count: 4)
    end
  end
end
