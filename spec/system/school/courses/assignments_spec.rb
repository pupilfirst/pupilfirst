require "rails_helper"

feature "Assignments", js: true do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:school_admin) { create :school_admin, school: school }
  let(:course) { create :course, school: school }
  let(:course_author) { create :course_author, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1, sort_index: 1 }

  context "when course doesn't have milestones" do
    scenario "school admin visits assignments page" do
      sign_in_user school_admin.user,
                   referrer: assignments_school_course_path(course)

      expect(page).to have_content(
        "No milestones found in this course. Create milestones by visiting curriculum page."
      )
    end
  end

  context "when course does have milestones" do
    let!(:target_1) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group,
             given_milestone_number: 1
    end
    let!(:target_2) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group,
             given_milestone_number: 2
    end

    scenario "school admin changes order of milestones" do
      sign_in_user school_admin.user,
                   referrer: assignments_school_course_path(course)

      expect(page).to have_text(target_1.title)
      expect(page).to have_text(target_2.title)

      # Move second target up.
      find('button[title="Move up"]').click

      within("div .target-group__target-container:last-child") do
        expect(page).to have_text(target_1.title)
      end

      expect(target_1.reload.assignments.first.milestone_number).to eq(2)
      expect(target_2.reload.assignments.first.milestone_number).to eq(1)

      # Move first target down.
      find('button[title="Move down"]').click

      within("div .target-group__target-container:last-child") do
        expect(page).to have_text(target_2.title)
      end

      expect(target_1.assignments.first.reload.milestone_number).to eq(1)
      expect(target_2.assignments.first.reload.milestone_number).to eq(2)
    end

    scenario "school admin clicks on milestone" do
      sign_in_user school_admin.user,
                   referrer: assignments_school_course_path(course)

      find(
        "a[href='#{details_school_course_target_path(course, target_1)}']"
      ).click

      expect(page).to have_text(target_1.title)
    end

    scenario "course author visit assignments page and changes order" do
      sign_in_user course_author.user,
                   referrer: assignments_school_course_path(course)

      expect(page).to have_text(target_1.title)
      expect(page).to have_text(target_2.title)

      find('button[title="Move up"]').click

      within("div .target-group__target-container:last-child") do
        expect(page).to have_text(target_1.title)
      end

      expect(target_1.assignments.first.reload.milestone_number).to eq(2)
      expect(target_2.assignments.first.reload.milestone_number).to eq(1)
    end
  end
end
