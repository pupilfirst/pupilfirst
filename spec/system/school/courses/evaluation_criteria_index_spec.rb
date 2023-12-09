require "rails_helper"

feature "Evaluation criteria index spec", js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with few evaluation criteria
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }

  let!(:school_admin) { create :school_admin, school: school }

  let(:author) { create :course_author, course: course }

  let!(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let!(:evaluation_criterion_2) { create :evaluation_criterion, course: course }

  let(:new_ec_name) { Faker::Lorem.words(number: 2).join(" ") }

  def label_for_grade(grade_labels, grade)
    grade_label =
      grade_labels.detect { |grade_label| grade_label["grade"] == grade }
    grade_label["label"]
  end

  scenario "school admin visits the evaluation criteria index for the course" do
    sign_in_user school_admin.user,
                 referrer: evaluation_criteria_school_course_path(course)

    expect(page).to have_text(evaluation_criterion_1.name)
    expect(page).to have_text(evaluation_criterion_2.name)
  end

  scenario "school admin adds a new criterion with labels" do
    sign_in_user school_admin.user,
                 referrer: evaluation_criteria_school_course_path(course)

    find("h5", text: "Add New Evaluation Criterion").click
    expect(page).to have_text("Maximum grade is")

    fill_in "Name", with: new_ec_name

    within('div[aria-label="label-editor"]') do
      expect(page).to have_selector("input", count: 5)
    end

    select "1", from: "max_grade"

    within('div[aria-label="label-editor"]') do
      expect(page).to have_selector("input", count: 1)
    end

    fill_in "grade-label-for-1", with: "Accepted"

    click_button "Create Criterion"

    expect(page).to have_text("Evaluation criterion created successfully")
    dismiss_notification

    expect(page).to have_text(new_ec_name)
    evaluation_criterion = course.evaluation_criteria.last

    expect(evaluation_criterion.name).to eq(new_ec_name)
    expect(evaluation_criterion.max_grade).to eq(1)

    expect(label_for_grade(evaluation_criterion.grade_labels, 1)).to eq(
      "Accepted"
    )
  end

  scenario "school admin adds a new criterion without labels" do
    sign_in_user school_admin.user,
                 referrer: evaluation_criteria_school_course_path(course)

    find("h5", text: "Add New Evaluation Criterion").click
    expect(page).to have_text("Maximum grade is")

    fill_in "Name", with: new_ec_name
    select "4", from: "max_grade", exact: true

    within('div[aria-label="label-editor"]') do
      expect(page).to have_selector("input", count: 4)
    end

    # Don't fill in labels; simply click the "Create Criterion" button.
    click_button "Create Criterion"

    expect(page).to have_text("Evaluation criterion created successfully")

    evaluation_criterion = course.evaluation_criteria.last

    expect(label_for_grade(evaluation_criterion.grade_labels, 1)).to eq("One")
    expect(label_for_grade(evaluation_criterion.grade_labels, 2)).to eq("Two")
    expect(label_for_grade(evaluation_criterion.grade_labels, 3)).to eq("Three")
    expect(label_for_grade(evaluation_criterion.grade_labels, 4)).to eq("Four")
  end

  scenario "school admin updates an evaluation criterion" do
    sign_in_user school_admin.user,
                 referrer: evaluation_criteria_school_course_path(course)

    find("button[title='Edit #{evaluation_criterion_1.name}']").click

    fill_in "Name", with: new_ec_name
    fill_in "grade-label-for-3", with: "New Label"

    click_button "Update Criterion"

    expect(page).to have_text("Evaluation criterion updated successfully")
    dismiss_notification

    evaluation_criterion_1.reload

    expect(evaluation_criterion_1.name).to eq(new_ec_name)
    expect(label_for_grade(evaluation_criterion_1.grade_labels, 3)).to eq(
      "New Label"
    )
  end

  scenario "school admin attempts to create a duplicate criterion" do
    sign_in_user school_admin.user,
                 referrer: evaluation_criteria_school_course_path(course)

    find("h5", text: "Add New Evaluation Criterion").click

    fill_in "Name", with: evaluation_criterion_1.name

    select evaluation_criterion_1.max_grade, from: "max_grade"

    click_button "Create Criterion"
    expect(page).to have_text(
      "A criterion already exists with this name and maximum grade"
    )
  end

  scenario "course author creates and edits a criterion" do
    sign_in_user author.user,
                 referrer: evaluation_criteria_school_course_path(course)
    find("h5", text: "Add New Evaluation Criterion").click
    fill_in "Name", with: new_ec_name
    click_button "Create Criterion"

    expect(page).to have_text("Evaluation criterion created successfully")

    dismiss_notification
    evaluation_criterion = course.evaluation_criteria.last

    expect(evaluation_criterion.name).to eq(new_ec_name)

    find("button[title='Edit #{evaluation_criterion.name}']").click
    another_name = Faker::Lorem.words(number: 2).join(" ")
    fill_in "Name", with: another_name
    click_button "Update Criterion"

    expect(page).to have_text("Evaluation criterion updated successfully")

    dismiss_notification

    expect(evaluation_criterion.reload.name).to eq(another_name)
  end

  scenario "user who is an author in another course will see a 404" do
    author_in_another_course = create :course_author
    sign_in_user author_in_another_course.user,
                 referrer: evaluation_criteria_school_course_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit evaluation_criteria_school_course_path(course)
    expect(page).to have_text("Please sign in to continue.")
  end
end
