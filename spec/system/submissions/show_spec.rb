require 'rails_helper'

feature 'Submissions show' do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:target) { create :target, :for_team, target_group: target_group }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let(:submission) { create(:timeline_event, target: target) }
  let(:submission_2) { create(:timeline_event, target: target) }

  let(:team) { create :startup, level: level }
  let(:student) { team.founders.first }

  context 'submission is of an evaluated target' do
    before do
      target.evaluation_criteria << [evaluation_criterion]

      submission.founders << student
      submission_2.founders << team.founders.last
    end

    scenario 'student visits show page of submission he is linked to', js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission)

      expect(page).to have_content(submission.title)
      expect(page).to have_content(submission.checklist.first['title'])
      expect(page).to have_content(submission.checklist.first['result'])
    end

    scenario 'student visits show page of submission he is not linked to', js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end

  context 'submission is of an auto-verified target' do
    before do
      submission.founders << student
    end

    scenario 'student visits show page of submission', js: true do
      sign_in_user student.user, referrer: timeline_event_path(submission)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end
end
