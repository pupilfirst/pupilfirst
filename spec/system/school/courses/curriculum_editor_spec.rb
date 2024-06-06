require "rails_helper"

feature "Curriculum Editor", js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  # Setup a course with a single student target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, :with_cohort, school: school }
  let!(:course_2) { create :course, :with_cohort, school: school }
  let!(:course_3) { create :course, :with_cohort, school: school }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:faculty) { create :faculty, school: school }
  let!(:course_author) do
    create :course_author, course: course, user: faculty.user
  end
  let!(:course_author_2) do
    create :course_author, course: course_2, user: faculty.user
  end
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:target_group_1) { create :target_group, level: level_1, sort_index: 1 }
  let!(:target_group_2) { create :target_group, level: level_2, sort_index: 1 }
  let!(:target_1) { create :target, target_group: target_group_1 }
  let!(:target_2) { create :target, target_group: target_group_1 }
  let!(:assignment_target_2) do
    create :assignment,
           :with_default_checklist,
           target: target_2,
           prerequisite_assignments: [target_5.assignments.first]
  end
  let!(:target_3) do
    create :target, :with_shared_assignment, target_group: target_group_2
  end
  let!(:target_4) { create :target, target_group: target_group_2 }
  let!(:assignment_target_4) do
    create :assignment,
           :with_default_checklist,
           target: target_4,
           prerequisite_assignments: [target_3.assignments.first]
  end

  # Target with contents
  let!(:target_5) do
    create :target,
           :with_content,
           :with_shared_assignment,
           target_group: target_group_2
  end

  # Data for level
  let(:new_level_name) { Faker::Lorem.sentence }
  let(:date) { Time.zone.today }

  # Data for target group 1
  let(:new_target_group_name) { Faker::Lorem.sentence }
  let(:new_target_group_description) { Faker::Lorem.sentence }

  # Data for target group 2
  let(:new_target_group_name_2) { Faker::Lorem.sentence }

  # Data for a normal target
  let(:new_target_1_title) { Faker::Lorem.sentence }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  scenario "admin creates a basic course framework by adding level, target group and targets" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course, level: 1)

    # When the level number is specified as a param, it should be selected.
    expect(page).to have_text(target_group_1.name)

    visit(curriculum_school_course_path(course))

    # Visiting the page without the level param should default selection to the max level, with all is targets and groups visible.
    expect(page).to have_text(target_group_2.name)
    expect(page).to have_text(target_3.title)
    expect(page).to have_text(target_4.title)

    # targets and target groups from other levels should not be visible
    expect(page).not_to have_text(target_group_1.name)
    expect(page).not_to have_text(target_1.title)
    expect(page).not_to have_text(target_2.title)

    # he should be able to create a new level
    click_button "Create Level"
    expect(page).to have_text("Level Name")
    fill_in "Level Name", with: new_level_name
    fill_in "Unlock level on", with: date.iso8601
    click_button "Create New Level"

    expect(page).to have_text("Level created successfully")
    dismiss_notification

    level = course.reload.levels.last
    expect(level.name).to eq(new_level_name)
    expect(level.unlock_at).to eq(Time.zone.now.beginning_of_day)

    # he should be able to edit the level
    find('button[title="Edit selected level"').click
    expect(page).to have_text(new_level_name)
    fill_in "Unlock level on", with: "", fill_options: { clear: :backspace }
    click_button "Update Level"

    expect(page).to have_text("Level updated successfully")
    dismiss_notification

    expect(level.reload.unlock_at).to eq(nil)

    # he should be able to create a new target group
    find(".target-group__create").click
    expect(page).to have_text("TARGET GROUP DETAILS")
    fill_in "Title", with: new_target_group_name
    replace_markdown(new_target_group_description, id: "description")
    click_button "Create Target Group"

    expect(page).to have_text("Target Group created successfully")
    dismiss_notification

    level.reload
    target_group = level.target_groups.last
    expect(target_group.name).to eq(new_target_group_name)
    expect(target_group.description).to eq(new_target_group_description)

    # he should be able to update a target group
    current_sort_index = target_group.sort_index
    find(".target-group__header", text: target_group.name).click
    expect(page).to have_text(target_group.name)
    expect(page).to have_text(target_group.description)
    fill_in "Description", with: "", fill_options: { clear: :backspace }

    click_button "Update Target Group"

    expect(page).to have_text("Target Group updated successfully")
    dismiss_notification

    target_group.reload
    expect(target_group.description).not_to eq(new_target_group_description)
    expect(target_group.sort_index).to eq(current_sort_index)

    # he should be able to create another target group
    find(".target-group__create").click
    expect(page).to have_text("TARGET GROUP DETAILS")
    fill_in "Title", with: new_target_group_name_2
    click_button "Create Target Group"

    expect(page).to have_text("Target Group created successfully")
    dismiss_notification

    # Update sort index
    find("#target-group-move-down-#{target_group.id}").click
    expect { target_group.reload.sort_index }.to eventually(eq 1)

    sleep 0.2

    find("#target-group-move-up-#{target_group.id}").click
    expect { target_group.reload.sort_index }.to eventually(eq 0)

    sleep 0.2

    # user should be able to create a draft target from the curriculum index
    find("#create-target-input#{target_group.id}").click
    fill_in "create-target-input#{target_group.id}", with: new_target_1_title
    click_button "Create"

    expect(page).to have_text("Target created successfully")
    dismiss_notification

    target = target_group.reload.targets.last

    expect(target.title).to eq(new_target_1_title)
    expect(page).to have_text(new_target_1_title)

    within("a#target-show-#{target.id}") { expect(page).to have_text("Draft") }
  end

  scenario "course author can navigate only to assigned courses and modify content of those courses" do
    sign_in_user course_author.user,
                 referrer: curriculum_school_course_path(course)

    click_button course.name

    expect(page).to have_link(
      course_2.name,
      href: "/school/courses/#{course_2.id}/curriculum"
    )
    expect(page).to_not have_link(
      course_3.name,
      href: "/school/courses/#{course_3.id}/curriculum"
    )

    click_link course_2.name

    expect(page).to have_button(course_2.name)
    expect(page).to_not have_link(href: "/school/coaches")
    expect(page).to_not have_link(href: "/school/customize")
    expect(page).to_not have_link(href: "/school/courses")
    expect(page).to_not have_link(href: "/school/communities")
    expect(page).to have_link(href: "/dashboard")

    [
      school_path,
      curriculum_school_course_path(course_3),
      school_communities_path,
      school_courses_path,
      customize_school_path
    ].each do |path|
      visit path

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end

    visit curriculum_school_course_path(course)
    find("#create-target-input#{target_group_2.id}").click
    fill_in "create-target-input#{target_group_2.id}", with: new_target_1_title
    click_button "Create"

    expect(page).to have_text("Target created successfully")

    dismiss_notification
  end

  scenario "author sets unlock date for a level that previously didn't have one" do
    sign_in_user course_author.user,
                 referrer: curriculum_school_course_path(course)

    find('button[title="Edit selected level"').click
    fill_in "Unlock level on", with: date.iso8601
    click_button "Update Level"

    expect(page).to have_text("Level updated successfully")
    expect(level_2.reload.unlock_at).to eq(Time.zone.now.beginning_of_day)
  end

  context "when there is a level zero and three other levels" do
    let(:level_0) { create :level, :zero, course: course }
    let(:level_3) { create :level, :three, course: course }
    let!(:target_group_l0) { create :target_group, level: level_0 }
    let!(:target_group_l3) { create :target_group, level: level_3 }
    let!(:student_l3) { create :student, cohort: course.cohorts.first }

    scenario "author merges third level into the first" do
      sign_in_user course_author.user,
                   referrer: curriculum_school_course_path(course)

      find('button[title="Edit selected level"').click
      click_button "Actions"
      select "L1: #{level_1.name}", from: "Delete & Merge Into"

      accept_confirm { click_button "Merge and Delete" }

      expect(page).to have_text(target_group_2.name)
      expect { level_3.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(target_group_l3.reload.level).to eq(level_1)
    end

    scenario "author is not allowed to merge third level into level zero" do
      sign_in_user course_author.user,
                   referrer: curriculum_school_course_path(course)

      find('button[title="Edit selected level"').click

      click_button "Actions"
      expect(page).not_to have_text("L0: #{level_0.name}")
    end
  end

  scenario "admin moves a target group from one level to another" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)
    find(".target-group__header", text: target_group_2.name).click

    expect(page).to have_text(
      "Level #{target_group_2.level.number}: #{target_group_2.level.name}"
    )

    fill_in "level_id", with: level_1.name
    click_button "Pick Level 1: #{level_1.name}"

    click_button "Update Target Group"
    expect(page).to have_text("Target Group updated successfully")
    dismiss_notification

    expect(target_group_2.reload.level).to eq(level_1)
    expect(target_group_2.sort_index).to eq(2)
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit curriculum_school_course_path(course)

    expect(page).to have_text("Please sign in to continue.")
  end

  scenario "The copy level function shouldn't be visible" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    find('button[title="Edit selected level"').click
    click_button "Actions"

    expect(page).not_to have_text("Copy Level")
  end

  context "with the clone_level feature enabled" do
    before { Flipper[:clone_level].enable }
    after { Flipper[:clone_level].disable }

    let!(:target_1) do
      create :target, :with_content, target_group: target_group_1
    end

    let!(:target_2) do
      create :target, :with_content, target_group: target_group_1
    end

    let!(:assignment_target_2) do
      create :assignment,
             :with_default_checklist,
             target: target_2,
             prerequisite_assignments: [target_5.assignments.first]
    end

    let!(:target_3) do
      create :target,
             :with_content,
             :with_shared_assignment,
             target_group: target_group_2
    end

    let!(:target_4) do
      create :target, :with_content, target_group: target_group_2
    end

    let!(:assignment_target_4) do
      create :assignment,
             target: target_4,
             prerequisite_assignments: [target_3.assignments.first]
    end

    scenario "admin copies a level into the same course" do
      sign_in_user school_admin.user,
                   referrer: curriculum_school_course_path(course)

      find('button[title="Edit selected level"').click
      click_button "Actions"

      find("div[data-course-id=\"#{course.name}\"]").click

      accept_confirm { click_button "Copy Level" }

      expect(page).to have_content(
        "Level copy requested. It will apppear in target course soon!"
      )

      visit curriculum_school_course_path(course)
      expect(all("option").last.text).to eq("Level 3: #{level_2.name}")
    end

    scenario "admin copies a level into another course" do
      sign_in_user school_admin.user,
                   referrer: curriculum_school_course_path(course)

      find('button[title="Edit selected level"').click
      click_button "Actions"

      find("div[data-course-id=\"#{course_2.name}\"]").click

      accept_confirm { click_button "Copy Level" }

      expect(page).to have_content(
        "Level copy requested. It will apppear in target course soon!"
      )

      visit curriculum_school_course_path(course_2)
      expect(all("option").last.text).to eq("Level 1: #{level_2.name}")
    end
  end

  context "when multiple levels have same name" do
    before do
      level_name = Faker::Lorem.words(number: 6).join(" ")
      level_1.update!(name: level_name)
      level_2.update!(name: level_name)
    end

    scenario "author goes through levels" do
      sign_in_user course_author.user,
                   referrer: curriculum_school_course_path(course)

      expect(page).to have_text(target_group_2.name)

      find("option[value=\"#{level_2.id}\"]").click
      find("option[value=\"#{level_1.id}\"]").click

      expect(page).to have_text(target_group_1.name)
    end
  end
end
