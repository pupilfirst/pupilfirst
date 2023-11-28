require "rails_helper"

feature "School Overview", js: true do
  include UserSpecHelper

  # Setup a course 1
  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  let!(:course_1) { create :course, school: school }
  let!(:cohort_1) { create :cohort, course: course_1 }
  let!(:c1_coach) { create :faculty, school: school }
  let!(:c1_faculty_cohort_enrollment) do
    create :faculty_cohort_enrollment, faculty: c1_coach, cohort: cohort_1
  end
  let!(:c1_evaluation_criterion) do
    create :evaluation_criterion, course: course_1
  end
  let!(:c1_level_1) { create :level, :one, course: course_1 }
  let!(:c1_level_2) { create :level, :two, course: course_1 }
  let!(:c1_target_group_1) { create :target_group, level: c1_level_1 }
  let!(:c1_target_1) do
    create :target,
           :with_shared_assignment,
           target_group: c1_target_group_1,
           given_evaluation_criteria: [c1_evaluation_criterion]
  end
  let!(:c1_target_2) do
    create :target,
           :with_shared_assignment,
           target_group: c1_target_group_1,
           given_evaluation_criteria: [c1_evaluation_criterion]
  end
  let!(:c1_team_1) { create :team_with_students, cohort: cohort_1 }
  let!(:c1_team_2) { create :team_with_students, cohort: cohort_1 }
  let!(:c1_team_3) { create :team_with_students, cohort: cohort_1 }
  let!(:c1_timeline_event_1) do
    create :timeline_event,
           :passed,
           evaluator_id: c1_coach.id,
           evaluated_at: 1.day.ago,
           students: c1_team_1.students,
           target: c1_target_1
  end
  let!(:c1_timeline_event_2) do
    create :timeline_event, students: c1_team_1.students, target: c1_target_2
  end
  let!(:c1_timeline_event_3) do
    create :timeline_event, students: c1_team_2.students, target: c1_target_1
  end
  let!(:c1_timeline_event_4) do
    create :timeline_event, students: c1_team_3.students, target: c1_target_1
  end

  # Setup a course 2
  let!(:course_2) { create :course, school: school }
  let(:cohort_2) { create :cohort, course: course_2 }
  let!(:c2_coach_1) { create :faculty, school: school }
  let!(:c2_coach_2) { create :faculty, school: school }
  let!(:c2_faculty_cohort_enrollment) do
    create :faculty_cohort_enrollment, faculty: c2_coach_1, cohort: cohort_2
  end
  let!(:c2_evaluation_criterion) do
    create :evaluation_criterion, course: course_2
  end
  let!(:c2_level_1) { create :level, :one, course: course_2 }
  let!(:c2_target_group_1) { create :target_group, level: c2_level_1 }
  let!(:c2_target_1) do
    create :target,
           :with_shared_assignment,
           target_group: c2_target_group_1,
           given_evaluation_criteria: [c2_evaluation_criterion]
  end
  let!(:c2_target_2) do
    create :target,
           :with_shared_assignment,
           target_group: c2_target_group_1,
           given_evaluation_criteria: [c2_evaluation_criterion]
  end
  let!(:c2_team_1) { create :team_with_students, cohort: cohort_2 }
  let!(:c2_team_2) { create :team_with_students, cohort: cohort_2 }
  let!(:c2_team_3) { create :team_with_students, cohort: cohort_2 }
  let!(:c2_faculty_student_enrollment) do
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: c2_coach_2,
           student: c2_team_1.students.first
  end
  let!(:c2_timeline_event_1) do
    create :timeline_event,
           :passed,
           evaluator_id: c2_coach_1.id,
           evaluated_at: 1.day.ago,
           students: c2_team_1.students,
           target: c2_target_1
  end
  let!(:c2_timeline_event_2) do
    create :timeline_event,
           :passed,
           evaluator_id: c2_coach_1.id,
           evaluated_at: 1.day.ago,
           students: c2_team_1.students,
           target: c2_target_2
  end
  let!(:c2_timeline_event_3) do
    create :timeline_event,
           :passed,
           evaluator_id: c2_coach_1.id,
           evaluated_at: 1.day.ago,
           students: c2_team_2.students,
           target: c2_target_1
  end
  let!(:c2_timeline_event_4) do
    create :timeline_event,
           :passed,
           evaluator_id: c2_coach_1.id,
           evaluated_at: 1.day.ago,
           students: c2_team_3.students,
           target: c2_target_1
  end

  let!(:course_ended) { create :course, :ended, school: school }
  let!(:course_archived) { create :course, :archived, school: school }

  scenario "school admin visit the school overview" do
    sign_in_user school_admin.user, referrer: school_path
    expect(page).to have_text(school.name)

    # gets the overall students count in school
    within("div[data-t='school students']") { expect(page).to have_text(12) }

    # gets the overall coaches count in school
    within("div[data-t='school coaches']") { expect(page).to have_text(3) }

    # gets the overall course overview for course 1
    within("div[data-t='#{course_1.name}']") do
      expect(page).to have_text(course_1.name)

      within("div[data-t='#{course_1.name} levels count']") do
        expect(page).to have_text(2)
      end

      within("div[data-t='#{course_1.name} cohorts count']") do
        expect(page).to have_text(1)
      end

      within("div[data-t='#{course_1.name} coaches count']") do
        expect(page).to have_text(1)
      end
    end

    # gets the overall course overview for course 2
    within("div[data-t='#{course_2.name}']") do
      expect(page).to have_text(course_2.name)

      within("div[data-t='#{course_2.name} levels count']") do
        expect(page).to have_text(1)
      end

      within("div[data-t='#{course_2.name} cohorts count']") do
        expect(page).to have_text(1)
      end

      within("div[data-t='#{course_2.name} coaches count']") do
        expect(page).to have_text(2)
      end
    end

    expect(page).not_to have_text(course_ended.name)
    expect(page).not_to have_text(course_archived.name)
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit school_path
    expect(page).to have_text("Please sign in to continue.")
  end
end
