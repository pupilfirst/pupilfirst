require 'rails_helper'

feature 'Submissions show' do
  include UserSpecHelper
  include ChecklistItemHelper

  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:target) { create :target, :for_team, target_group: target_group }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:submission_file_1) { create :timeline_event_file }

  let(:submission_file_2) do
    create :timeline_event_file, file_path: 'files/icon_pupilfirst.png'
  end

  let(:submission_audio_file) do
    create :timeline_event_file, file_path: 'files/audio_file_sample.mp3'
  end

  let(:checklist_item_long_text) do
    checklist_item(Target::CHECKLIST_KIND_LONG_TEXT, Faker::Lorem.sentence)
  end

  let(:checklist_item_short_text) do
    checklist_item(Target::CHECKLIST_KIND_SHORT_TEXT, Faker::Lorem.sentence)
  end

  let(:checklist_item_link) do
    checklist_item(Target::CHECKLIST_KIND_LINK, 'https://www.example.com')
  end

  let(:checklist_item_files) do
    checklist_item(
      Target::CHECKLIST_KIND_FILES,
      [submission_file_1.id, submission_file_2.id]
    )
  end

  let(:checklist_item_audio) do
    checklist_item(Target::CHECKLIST_KIND_AUDIO, submission_audio_file.id)
  end

  let(:checklist_item_multi_choice) do
    checklist_item(Target::CHECKLIST_KIND_MULTI_CHOICE, 'Yes')
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
  let(:team) { create :team_with_students, cohort: cohort }
  let(:student) { team.students.first }

  before do
    # Link submission files after they are created.
    submission_file_1.update!(timeline_event: submission)
    submission_file_2.update!(timeline_event: submission)
    submission_audio_file.update!(timeline_event: submission)
  end

  context 'submission is of an evaluated target' do
    before do
      target.evaluation_criteria << [evaluation_criterion]

      submission.students << student
      submission_2.students << team.students.last
    end

    scenario 'student visits show page of submission he is linked to',
             js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission)

      expect(page).to have_content(submission.title)
      expect(page).to have_content(checklist_item_long_text['title'])
      expect(page).to have_content(checklist_item_long_text['result'])
      expect(page).to have_content(checklist_item_short_text['title'])
      expect(page).to have_content(checklist_item_short_text['result'])
      expect(page).to have_content(checklist_item_multi_choice['title'])
      expect(page).to have_content('Yes')
      expect(page).to have_content(checklist_item_link['title'])

      expect(page).to have_link(
        'https://www.example.com',
        href: 'https://www.example.com'
      )

      expect(page).to have_content(checklist_item_files['title'])

      expect(page).to have_link(
        'pdf-sample.pdf',
        href: download_timeline_event_file_path(submission_file_1)
      )

      expect(page).to have_link(
        'icon_pupilfirst.png',
        href: download_timeline_event_file_path(submission_file_2)
      )

      expect(page).to have_content(checklist_item_audio['title'])
      expect(page).to have_selector('audio')
    end

    scenario 'student visits show page of submission he is not linked to',
             js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end

  context 'submission is of an auto-verified target' do
    before { submission.students << student }

    scenario 'student visits show page of submission', js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end
end
