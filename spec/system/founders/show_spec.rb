require 'rails_helper'

feature 'Founder Show' do
  include UserSpecHelper
  include FounderSpecHelper

  # Setup a course with a single founder target, ...
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let(:target_1) { create :target, :for_founders, target_group: target_group }
  let(:target_2) { create :target, :for_startup, target_group: target_group }
  let(:target_3) { create :target, :for_startup, target_group: target_group }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:startup) { create :startup, level: level_1 }
  let(:founder) { create :founder, startup: startup }
  let!(:timeline_event_1) { create :timeline_event, target: target_1, passed_at: 1.day.ago, founders: [founder] }
  let!(:timeline_event_2) { create :timeline_event, target: target_2, passed_at: 1.day.ago, founders: [founder] }
  let!(:timeline_event_3) { create :timeline_event, target: target_3, founders: [founder] }

  scenario 'Public user visits a student profile' do
    visit student_path(founder.slug)
    # ensure founder is on his profile
    expect(page).to have_text(founder.fullname)
    # ensure course name displayed is correct
    expect(page).to have_text(course.name)
    # ensure level name displayed is correct
    expect(page).to have_text(level_1.name)

    # Verified team event should be visible.
    expect(page).to have_text(timeline_event_2.description)

    # Other events should not be displayed.
    expect(page).not_to have_text(timeline_event_1.description)
    expect(page).not_to have_text(timeline_event_3.description)
  end

  scenario 'Active founder visits his profile' do
    sign_in_user(founder.user, referer: student_path(founder.slug))

    # All events should be visible.
    expect(page).to have_text(timeline_event_1.description)
    expect(page).to have_text(timeline_event_2.description)
    expect(page).to have_text(timeline_event_3.description)
  end
end
