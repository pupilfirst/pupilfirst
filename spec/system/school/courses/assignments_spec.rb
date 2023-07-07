require "rails_helper"

feature "Assignments", js: true do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:school_admin) { create :school_admin, school: school }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1, sort_index: 1 }

  context "when course doesn't have milestones" do
    scenario "school admin visits assignments page" do
      sign_in_user school_admin.user,
                   referrer: assignments_school_course_path(course)

      expect(page).to have_content(
        "No milestone targets present in this course."
      )
    end
  end

  context "when course does have milestones" do
    let!(:target_1) do
      create :target,
             :student,
             target_group: target_group,
             milestone: true,
             milestone_number: 1
    end
    let!(:target_2) do
      create :target,
             :student,
             target_group: target_group,
             milestone: true,
             milestone_number: 2
    end

    scenario "school admin changes order of milestones" do
      sign_in_user school_admin.user,
                   referrer: assignments_school_course_path(course)

      expect(page).to have_text(target_1.title)
      expect(page).to have_text(target_2.title)

      # Test down button.
      find_all("button[type='submit']").first.click

      expect(target_1.reload.milestone_number).to eq(2)
      expect(target_2.reload.milestone_number).to eq(1)

      # Test up button.
      find_all("button[type='submit']").last.click

      expect(target_1.reload.milestone_number).to eq(1)
      expect(target_2.reload.milestone_number).to eq(2)
    end

    scenario "school admin clicks on milestone" do
      sign_in_user school_admin.user,
                   referrer: assignments_school_course_path(course)

      find(
        "a[href='#{details_school_course_target_path(course, target_1)}']"
      ).click

      expect(page).to have_text(target_1.title)
    end
  end
end
