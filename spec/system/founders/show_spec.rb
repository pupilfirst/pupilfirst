require 'rails_helper'

feature 'Founder Show' do
  include UserSpecHelper
  # Setup a course with a single founder target, ...
  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let(:target) { create :target, :for_founders, target_group: target_group }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:startup) { create :startup, level: level_1 }
  let(:founder) { create :founder, startup: startup }
  let!(:timeline_event_1) { create :timeline_event, target: target, passed_at: 1.day.ago, founders: [founder] }

  scenario 'Public user visits a student profile' do
    visit student_path(founder.slug)
    # ensure founder is on his profile
    expect(page).to have_text(founder.fullname)
    # ensure course name displayed is correct
    expect(page).to have_text(course.name)
    # ensure level name displayed is correct
    expect(page).to have_text(level_1.name)
    # ensure founder timeline event are not displayed on the profile
    expect(page).to have_text('No timeline events to show')
  end

  scenario 'Active founder visits his profile' do
    sign_in_user(founder.user, referer: student_path(founder.slug))

    # ensure founder timeline event are displayed on the profile
    expect(page).to have_text(timeline_event_1.description)
  end
end
