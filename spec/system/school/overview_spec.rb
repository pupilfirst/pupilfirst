require 'rails_helper'

feature 'School Overview', js: true do
  include UserSpecHelper

  # Setup a course 1
  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  let!(:course_1) { create :course, school: school }
  let!(:c1_coach) { create :faculty, school: school }
  let!(:c1_faculty_course_enrollment) { create :faculty_course_enrollment, faculty: c1_coach, course: course_1 }
  let!(:c1_evaluation_criterion) { create :evaluation_criterion, course: course_1 }
  let!(:c1_level_1) { create :level, :one, course: course_1 }
  let!(:c1_level_2) { create :level, :two, course: course_1 }
  let!(:c1_target_group_1) { create :target_group, level: c1_level_1 }
  let!(:c1_target_1) { create :target, target_group: c1_target_group_1, evaluation_criteria: [c1_evaluation_criterion] }
  let!(:c1_target_2) { create :target, target_group: c1_target_group_1, evaluation_criteria: [c1_evaluation_criterion] }
  let!(:c1_startup_1) { create :startup, level: c1_level_1 }
  let!(:c1_startup_2) { create :startup, level: c1_level_1 }
  let!(:c1_startup_3) { create :startup, level: c1_level_1 }
  let!(:c1_timeline_event_1) { create :timeline_event, :passed, evaluator_id: c1_coach.id, evaluated_at: 1.day.ago, founders: c1_startup_1.founders, target: c1_target_1 }
  let!(:c1_timeline_event_2) { create :timeline_event, founders: c1_startup_1.founders, target: c1_target_2 }
  let!(:c1_timeline_event_3) { create :timeline_event, founders: c1_startup_2.founders, target: c1_target_1 }
  let!(:c1_timeline_event_4) { create :timeline_event, founders: c1_startup_3.founders, target: c1_target_1 }

  # Setup a course 2
  let!(:course_2) { create :course, school: school }
  let!(:c2_coach_1) { create :faculty, school: school }
  let!(:c2_coach_2) { create :faculty, school: school }
  let!(:c2_faculty_course_enrollment) { create :faculty_course_enrollment, faculty: c2_coach_1, course: course_2 }
  let!(:c2_evaluation_criterion) { create :evaluation_criterion, course: course_2 }
  let!(:c2_level_1) { create :level, :one, course: course_2 }
  let!(:c2_target_group_1) { create :target_group, level: c2_level_1 }
  let!(:c2_target_1) { create :target, target_group: c2_target_group_1, evaluation_criteria: [c2_evaluation_criterion] }
  let!(:c2_target_2) { create :target, target_group: c2_target_group_1, evaluation_criteria: [c2_evaluation_criterion] }
  let!(:c2_startup_1) { create :startup, level: c2_level_1 }
  let!(:c2_startup_2) { create :startup, level: c2_level_1 }
  let!(:c2_startup_3) { create :startup, level: c2_level_1 }
  let!(:c2_faculty_startup_enrollment) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: c2_coach_2, startup: c2_startup_1 }
  let!(:c2_timeline_event_1) { create :timeline_event, :passed, evaluator_id: c2_coach_1.id, evaluated_at: 1.day.ago, founders: c2_startup_1.founders, target: c2_target_1 }
  let!(:c2_timeline_event_2) { create :timeline_event, :passed, evaluator_id: c2_coach_1.id, evaluated_at: 1.day.ago, founders: c2_startup_1.founders, target: c2_target_2 }
  let!(:c2_timeline_event_3) { create :timeline_event, :passed, evaluator_id: c2_coach_1.id, evaluated_at: 1.day.ago, founders: c2_startup_2.founders, target: c2_target_1 }
  let!(:c2_timeline_event_4) { create :timeline_event, :passed, evaluator_id: c2_coach_1.id, evaluated_at: 1.day.ago, founders: c2_startup_3.founders, target: c2_target_1 }

  scenario 'school admin visit the school overview' do
    sign_in_user school_admin.user, referrer: school_path
    expect(page).to have_text(school.name)

    # gets the overall students count in school
    within("div[data-t='school students']") do
      expect(page).to have_text(12)
    end

    # gets the overall coaches count in school
    within("div[data-t='school coaches']") do
      expect(page).to have_text(3)
    end

    # gets the overall course overview for course 1
    within("div[data-t='#{course_1.name} details']") do
      expect(page).to have_text(course_1.name)
      expect(page).to have_text("2 Levels")

      within("div[data-t='#{course_1.name} students']") do
        expect(page).to have_text(6)
      end

      within("div[data-t='#{course_1.name} coaches']") do
        expect(page).to have_text(1)
      end

      expect(page).to have_text("1/4 submissions reviewed.")
    end

    # gets the overall course overview for course 2
    within("div[data-t='#{course_2.name} details']") do
      expect(page).to have_text(course_2.name)

      within("div[data-t='#{course_2.name} students']") do
        expect(page).to have_text(6)
      end

      within("div[data-t='#{course_2.name} coaches']") do
        expect(page).to have_text(2)
      end

      expect(page).to have_text("4/4 submissions reviewed.")
    end
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_path
    expect(page).to have_text("Please sign in to continue.")
  end
end
