require "rails_helper"

feature "Submissions show" do
  include UserSpecHelper
  include ChecklistItemHelper

  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group
  end
  let(:target_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:submission_file_1) { create :timeline_event_file }

  let(:submission_file_2) do
    create :timeline_event_file, file_path: "files/icon_pupilfirst.png"
  end

  let(:submission_audio_file) do
    create :timeline_event_file, file_path: "files/audio_file_sample.mp3"
  end

  let(:checklist_item_long_text) do
    checklist_item(Assignment::CHECKLIST_KIND_LONG_TEXT, Faker::Lorem.sentence)
  end

  let(:checklist_item_short_text) do
    checklist_item(Assignment::CHECKLIST_KIND_SHORT_TEXT, Faker::Lorem.sentence)
  end

  let(:checklist_item_link) do
    checklist_item(Assignment::CHECKLIST_KIND_LINK, "https://www.example.com")
  end

  let(:checklist_item_files) do
    checklist_item(
      Assignment::CHECKLIST_KIND_FILES,
      [submission_file_1.id, submission_file_2.id]
    )
  end

  let(:checklist_item_audio) do
    checklist_item(Assignment::CHECKLIST_KIND_AUDIO, submission_audio_file.id)
  end

  let(:checklist_item_multi_choice) do
    checklist_item(Assignment::CHECKLIST_KIND_MULTI_CHOICE, ["Yes"])
  end

  let(:checklist) do
    [
      checklist_item_long_text,
      checklist_item_short_text,
      checklist_item_link,
      checklist_item_files,
      checklist_item_audio,
      checklist_item_multi_choice
    ]
  end

  let(:submission) do
    create(:timeline_event, target: target, checklist: checklist)
  end

  let(:submission_2) { create(:timeline_event, target: target) }
  let(:submission_3) { create(:timeline_event, target: target_2) }

  let(:team) { create :team_with_students, cohort: cohort }
  let(:student) { team.students.first }
  let(:student_2) { team.students.last }

  let(:organisation) { create :organisation, school: school }
  let(:organisation_admin) do
    create :organisation_admin, organisation: organisation
  end

  let(:coach) { create :faculty, school: school }
  let(:coach_2) { create :faculty, school: school }

  let!(:feedback_1) do
    create :startup_feedback,
           timeline_event_id: submission.id,
           faculty_id: coach.id
  end
  let!(:feedback_2) do
    create :startup_feedback,
           timeline_event_id: submission.id,
           faculty_id: coach_2.id
  end

  before do
    # Link submission files after they are created.
    submission_file_1.update!(timeline_event: submission)
    submission_file_2.update!(timeline_event: submission)
    submission_audio_file.update!(timeline_event: submission)
  end

  context "submission is of an evaluated target" do
    before do
      student.user.update!(organisation: organisation)

      target.assignments.first.evaluation_criteria << [evaluation_criterion]
      target_2.assignments.first.evaluation_criteria << [evaluation_criterion]
      submission.students << [student, student_2]
      submission_2.students << student_2
      submission_3.students << student
      submission.update!(evaluator: coach)
      submission.update!(evaluated_at: Time.now)
    end

    scenario "org admin vsits show page with a submission" do
      sign_in_user organisation_admin.user,
                   referrer: timeline_event_path(submission)

      expect(page).to have_text(submission.title)
    end

    scenario "student visits show page of submission he is linked to",
             js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission)

      expect(page).to have_content(submission.title)
      expect(page).to have_content(student.name)
      expect(page).to have_content(student_2.name)
      expect(page).to have_content(team.name)

      expect(page).to have_content(
        submission
          .created_at
          .in_time_zone(student.user.time_zone)
          .strftime("%b %d, %Y")
      )

      expect(page).to have_content("Rejected")
      expect(page).to have_content(checklist_item_long_text["title"])
      expect(page).to have_content(checklist_item_long_text["result"])
      expect(page).to have_content(checklist_item_short_text["title"])
      expect(page).to have_content(checklist_item_short_text["result"])
      expect(page).to have_content(checklist_item_multi_choice["title"])
      expect(page).to have_content("Yes")
      expect(page).to have_content(checklist_item_link["title"])

      expect(page).to have_link(
        "https://www.example.com",
        href: "https://www.example.com"
      )

      expect(page).to have_content(checklist_item_files["title"])

      expect(page).to have_link(
        "pdf-sample.pdf",
        href: download_timeline_event_file_path(submission_file_1)
      )

      expect(page).to have_link(
        "icon_pupilfirst.png",
        href: download_timeline_event_file_path(submission_file_2)
      )

      expect(page).to have_content(checklist_item_audio["title"])
      expect(page).to have_selector("audio")

      expect(page).to have_text(feedback_1.feedback)
      expect(page).to have_text(feedback_2.feedback)
      expect(page).to have_text(coach.name)
      expect(page).to have_text(coach_2.name)
    end

    scenario "student visits show page with a submission for target having student role",
             js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission_3)

      expect(page).to have_text(submission_3.title)
      expect(page).to have_text(student.name)
      expect(page).to have_text("Pending")
      expect(page).not_to have_text(student_2.name)
      expect(page).not_to have_text(team.name)
    end

    scenario "student visits show page of submission he is not linked to",
             js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end
end
