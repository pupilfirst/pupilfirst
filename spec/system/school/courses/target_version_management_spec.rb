require 'rails_helper'

feature 'Target Content Version Management', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with few targets to modify content
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:level_1) { create :level, :one, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_1) { create :target, :with_content, target_group: target_group_1 }
  let!(:coach) { create :faculty, school: school }
  let!(:course_author) { create :course_author, course: course, user: coach.user }

  # rubocop:disable Rails/SkipsModelValidations
  context 'admin visits target version page' do
    scenario 'creates a target version', js: true do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      # Open the versions editor for the target.
      find("a[title='Edit versions of target #{target_1.title}']").click
      expect(page).to have_text(target_1.title)

      expect(target_1.target_versions.count).to eq(1)
      content_blocks_v1 = target_1.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) }

      click_button 'Save this version'
      expect(page).to have_text('A new version has been created')
      dismiss_notification

      expect(page).to have_text('#2')
      expect(target_1.target_versions.count).to eq(2)
      expect(target_1.current_target_version.content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) }).to match_array(content_blocks_v1)
    end

    scenario 'creates multiple target versions', js: true do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      # Open the versions editor for the target.
      find("a[title='Edit versions of target #{target_1.title}']").click
      expect(page).to have_text(target_1.title)

      click_button 'Save this version'
      expect(page).to have_text('A new version has been created')
      dismiss_notification

      expect(page).to have_text('#2')
      click_button 'Save this version'
      expect(page).to have_text('There are no changes from the previous version. Please make changes before trying to save this version.')
      dismiss_notification

      target_1.current_target_version.touch
      click_button 'Save this version'
      expect(page).to have_text('A new version has been created')
      dismiss_notification

      expect(page).to have_text('#3')
      target_1.current_target_version.touch
      click_button 'Save this version'
      expect(page).to have_text('You cannot create more than 3 versions per day')
      dismiss_notification
    end

    scenario 'restores to an old version', js: true do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      # Open the versions editor for the target.
      find("a[title='Edit versions of target #{target_1.title}']").click
      expect(page).to have_text(target_1.title)

      expect(target_1.target_versions.count).to eq(1)
      target_version_v1 = target_1.target_versions.first
      content_blocks_v1 = target_1.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) }

      click_button 'Save this version'
      expect(page).to have_text('A new version has been created')
      dismiss_notification

      expect(page).to have_text('#2')
      target_1.current_target_version.content_blocks.last.delete
      target_1.current_target_version.touch

      click_button "Select version #{target_1.current_target_version.id}"
      click_button "Select version #{target_version_v1.id}"

      click_button 'Restore this version'
      expect(page).to have_text('A new version has been created')
      dismiss_notification

      expect(page).to have_text('#3')
      expect(target_1.current_target_version.content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) }).to match_array(content_blocks_v1)
    end
  end

  context 'course author visits target version page' do
    scenario 'creates a target version', js: true do
      sign_in_user course_author.user, referer: curriculum_school_course_path(course)

      # Open the versions editor for the target.
      find("a[title='Edit versions of target #{target_1.title}']").click
      expect(page).to have_text(target_1.title)

      expect(target_1.target_versions.count).to eq(1)
      content_blocks_v1 = target_1.current_content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) }

      click_button 'Save this version'
      expect(page).to have_text('A new version has been created')
      dismiss_notification

      expect(page).to have_text('#2')
      expect(target_1.target_versions.count).to eq(2)
      expect(target_1.current_target_version.content_blocks.order(:sort_index).map { |cb| cb.slice(:block_type, :content, :sort_index) }).to match_array(content_blocks_v1)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
