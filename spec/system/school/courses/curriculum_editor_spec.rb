require 'rails_helper'

feature 'Curriculum Editor', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:course_2) { create :course, school: school }
  let!(:course_3) { create :course, school: school }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:faculty) { create :faculty, school: school }
  let!(:course_author) { create :course_author, course: course, user: faculty.user }
  let!(:course_author_2) { create :course_author, course: course_2, user: faculty.user }
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_group_2) { create :target_group, level: level_2 }
  let!(:target_1) { create :target, target_group: target_group_1 }
  let!(:target_2) { create :target, target_group: target_group_1 }
  let!(:target_3) { create :target, target_group: target_group_2 }
  let!(:target_4) { create :target, target_group: target_group_2 }
  # Target with contents
  let!(:target_5) { create :target, :with_content, target_group: target_group_2 }

  # Data for level
  let(:new_level_name) { Faker::Lorem.sentence }
  let(:date) { Date.today }

  # Data for target group 1
  let(:new_target_group_name) { Faker::Lorem.sentence }
  let(:new_target_group_description) { Faker::Lorem.sentence }

  # Data for target group 2
  let(:new_target_group_name_2) { Faker::Lorem.sentence }

  # Data for a normal target
  let(:new_target_1_title) { Faker::Lorem.sentence }

  # Data for a mark as complete target
  let(:new_target_2_title) { Faker::Lorem.sentence }

  # Data for a target with link to complete
  let(:new_target_3_title) { Faker::Lorem.sentence }
  let(:link_to_complete) { Faker::Internet.url }

  # Data for a target with quiz
  let(:new_target_4_title) { Faker::Lorem.sentence }

  let(:quiz_question_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_2) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3_hint) { Faker::Lorem.sentence }

  let(:quiz_question_2) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_2) { Faker::Lorem.sentence }

  let(:sample_markdown_text) { Faker::Markdown.sandwich(6) }
  let(:completion_instructions) { Faker::Lorem.sentence }

  before do
    stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=3QDYbQIS8cQ').to_return(body: '{"version":"1.0","provider_name":"YouTube","html":"\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e","thumbnail_url":"https:\/\/i.ytimg.com\/vi\/3QDYbQIS8cQ\/hqdefault.jpg","provider_url":"https:\/\/www.youtube.com\/","thumbnail_height":360,"type":"video","height":270,"thumbnail_width":480,"author_url":"https:\/\/www.youtube.com\/channel\/UCvsvW3QH1700y-j2VfEnq-A","author_name":"Just smile","title":"Funny And Cute Cats - Funniest Cats Compilation 2019","width":480}', status: 200) # rubocop:disable Metrics/LineLength
  end

  def file_path(filename)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'files', filename))
  end

  def latest_content_versions(target)
    target.content_versions.reload.where(version_on: target.latest_content_version_date)
  end

  context 'authorized user creates the curriculum' do
    scenario 'creates a basic course framework by adding level, target group and targets' do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      # he should be on the last level
      expect(page).to have_text("Level 2: " + level_2.name)

      # all targets and target groups on that level should be visible
      expect(page).to have_text(target_group_2.name)
      expect(page).to have_text(target_3.title)
      expect(page).to have_text(target_4.title)

      # targets and target groups from other levels should not be visible
      expect(page).not_to have_text(target_group_1.name)
      expect(page).not_to have_text(target_1.title)
      expect(page).not_to have_text(target_2.title)

      # he should be able to create a new level
      click_button 'Create Level'
      expect(page).to have_text("Level Name")
      fill_in 'Level Name', with: new_level_name
      fill_in 'Unlock level on', with: date.iso8601
      click_button 'Create New Level'

      expect(page).to have_text("Level created successfully")
      dismiss_notification

      level = course.reload.levels.last
      expect(level.name).to eq(new_level_name)
      expect(level.unlock_on).to eq(date)

      # he should be able to edit the level
      click_button 'edit'
      expect(page).to have_text(new_level_name)
      fill_in 'Unlock level on', with: '', fill_options: { clear: :backspace }
      click_button 'Update Level'

      expect(page).to have_text('Level updated successfully')
      dismiss_notification

      expect(level.reload.unlock_on).to eq(nil)

      # he should be able to create a new target group
      find('.target-group__create').click
      expect(page).to have_text('TARGET GROUP DETAILS')
      fill_in 'Title', with: new_target_group_name
      fill_in 'Description', with: new_target_group_description
      click_button 'Yes'
      click_button 'Create Target Group'

      expect(page).to have_text('Target Group created successfully')
      dismiss_notification

      level.reload
      target_group = level.target_groups.last
      expect(target_group.name).to eq(new_target_group_name)
      expect(target_group.description).to eq(new_target_group_description)
      expect(target_group.milestone).to eq(true)

      # he should be able to update a target group
      find('.target-group__header', text: target_group.name).click
      expect(page).to have_text(target_group.name)
      expect(page).to have_text(target_group.description)
      fill_in 'Description', with: '', fill_options: { clear: :backspace }

      within('.milestone') do
        click_button 'No'
      end

      click_button 'Update Target Group'

      expect(page).to have_text("Target Group updated successfully")
      dismiss_notification

      target_group.reload
      expect(target_group.description).not_to eq(new_target_group_description)
      expect(target_group.milestone).to eq(false)

      # he should be able to create another target group
      find('.target-group__create').click
      expect(page).to have_text('TARGET GROUP DETAILS')
      fill_in 'Title', with: new_target_group_name_2
      click_button 'Yes'
      click_button 'Create Target Group'

      expect(page).to have_text('Target Group created successfully')
      dismiss_notification

      # Update sort index
      find("#target-group-move-down-#{target_group.id}").click
      expect { target_group.reload.sort_index }.to eventually(eq 1)

      # TODO: This section of the spec is flaky. The sleep is here to try and avoid a failure to click properly.
      sleep 0.2

      find("#target-group-move-up-#{target_group.id}").click
      expect { target_group.reload.sort_index }.to eventually(eq 0)

      # user should be able to create a draft target from the curriculum index
      find("#create-target-input#{target_group.id}").click
      fill_in "create-target-input#{target_group.id}", with: new_target_1_title
      click_button 'Create'

      expect(page).to have_text('Target created successfully')
      dismiss_notification

      click_button 'Edit'

      # Allow adding a new content block and deleting the sample block
      find("div#add-block-1", visible: false).click
      within("div#content-type-picker-1") do
        find('p', text: 'Markdown').click
      end

      replace_markdown(sample_markdown_text)
      find('span', text: 'Preview').click
      click_button 'Save'
      expect(page).to have_text('Content added successfully')
      dismiss_notification

      accept_confirm do
        within('#content-block-controls-2') do
          find_button('Delete block').click
        end
      end

      click_button 'Next Step'
      find('span', text: 'Add Content').click

      expect(page).to have_selector('.content-block__content', count: 1)
      expect(page).to have_selector('.add-content-block--open', count: 1)
      target = target_group.reload.targets.last
      expect(target.title).to eq(new_target_1_title)
      find('#target-editor-close').click
      expect(page).to have_text(new_target_1_title)

      within("div#target-show-#{target.id}") do
        expect(page).to have_text('Draft')
      end
    end
  end

  context 'authorized user creates different types of targets' do
    scenario 'creates a target with a link to complete' do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      find("#create-target-input#{target_group_2.id}").click
      fill_in "create-target-input#{target_group_2.id}", with: new_target_3_title
      click_button 'Create'

      expect(page).to have_text("Target created successfully")
      dismiss_notification

      click_button 'Next Step'
      expect(page).to have_text('Any prerequisite targets?')

      within("div#evaluated") do
        click_button 'No'
      end

      within("div#method_of_completion") do
        click_button 'Visit a link to complete the target.'
      end

      fill_in 'Link to complete', with: link_to_complete

      within("div#visibility") do
        click_button 'Live'
      end

      click_button 'Update Target'

      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      expect(page).to have_text("Create a target")
      target = Target.find_by(title: new_target_3_title)
      expect(target.evaluation_criteria).to eq([])
      expect(target.link_to_complete).to eq(link_to_complete)
      expect(target.quiz).to eq(nil)

      # Update sort index
      find("#target-move-up-#{target.id}").click
      expect { target.reload.sort_index }.to eventually(eq 2)
      find("#target-move-down-#{target.id}").click
      expect { target.reload.sort_index }.to eventually(eq 3)
    end

    scenario 'creates a target with a quiz' do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      find("#create-target-input#{target_group_2.id}").click
      fill_in "create-target-input#{target_group_2.id}", with: new_target_4_title

      click_button 'Create'
      dismiss_notification
      expect(page).to have_text('Markdown editor')
      click_button 'Next Step'

      within("div#evaluated") do
        click_button 'No'
      end

      within("div#method_of_completion") do
        click_button 'Take a quiz to complete the target.'
      end

      # Quiz Question 1
      replace_markdown(quiz_question_1)
      click_button 'Preview'
      fill_in 'quiz_question_1_answer_option_1', with: quiz_question_1_answer_option_1
      fill_in 'quiz_question_1_answer_option_2', with: quiz_question_1_answer_option_2
      find("a", text: "Add another Answer Option").click
      fill_in 'quiz_question_1_answer_option_3', with: quiz_question_1_answer_option_3

      within("div#quiz_question_1_answer_option_3_block") do
        click_button 'Mark as correct'
      end

      # Quiz Question 2
      find("a", text: "Add another Question").click
      replace_markdown(quiz_question_2)
      fill_in 'quiz_question_2_answer_option_1', with: quiz_question_2_answer_option_1
      fill_in 'quiz_question_2_answer_option_2', with: quiz_question_2_answer_option_2

      within("div#visibility") do
        click_button 'Live'
      end

      click_button 'Update Target'

      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      expect(page).to have_text("Create a target")

      target = Target.find_by(title: new_target_4_title)
      expect(target.evaluation_criteria).to eq([])
      expect(target.link_to_complete).to eq(nil)
      expect(target.quiz.title).to eq(new_target_4_title)
      expect(target.quiz.quiz_questions.count).to eq(2)
      expect(target.quiz.quiz_questions.first.question).to eq(quiz_question_1)
      expect(target.quiz.quiz_questions.first.correct_answer.value).to eq(quiz_question_1_answer_option_3)
      expect(target.quiz.quiz_questions.last.question).to eq(quiz_question_2)
      expect(target.quiz.quiz_questions.last.correct_answer.value).to eq(quiz_question_2_answer_option_1)

      find('.target-group__target', text: new_target_4_title).click
      expect(page).to have_text('Markdown editor')
      click_button 'Next Step'

      expect(page).to have_text('Any prerequisite targets?')

      within("div#evaluated") do
        click_button 'No'
      end

      within("div#method_of_completion") do
        click_button 'Simply mark the target as completed.'
      end

      click_button 'Update Target'

      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      expect(target.reload.evaluation_criteria).to eq([])
      expect(target.link_to_complete).to eq(nil)
      expect(target.quiz).to eq(nil)
    end
  end

  context 'authorized users modifies a target' do
    scenario 'adds content to a target and modifies its properties' do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      target = target_4

      # update target completion_instructions
      find('.target-group__target', text: target.title).click
      expect(page).to have_selector('.add-content-block--open', count: 1)
      click_button 'Next Step'
      expect(page).to have_text('Do you have any completion instructions for the student?')
      fill_in 'completion-instructions', with: completion_instructions

      click_button 'Update Target'
      dismiss_notification

      expect(target.reload.completion_instructions).to eq(completion_instructions)

      find('.target-group__target', text: target.title).click
      expect(page).to have_selector('.add-content-block--open', count: 1)
      click_button 'Next Step'
      expect(page).to have_text('Do you have any completion instructions for the student?')
      fill_in 'completion-instructions', with: '', fill_options: { clear: :backspace }

      click_button 'Update Target'
      dismiss_notification

      expect(target.reload.completion_instructions).to eq(nil)

      # Change target visibility
      find('.target-group__target', text: target.title).click
      expect(page).to have_selector('.add-content-block--open', count: 1)
      click_button 'Next Step'
      expect(page).to have_text('Target Visibility')

      within("div#visibility") do
        click_button 'Live'
      end

      click_button 'Update Target'
      dismiss_notification

      within("div#target-show-#{target.id}") do
        expect(page).to_not have_text('Draft')
      end

      expect(target.reload.visibility).to eq('live')
      find('.target-group__target', text: target.title).click
      expect(page).to have_selector('.add-content-block--open', count: 1)
      click_button 'Next Step'

      within("div#visibility") do
        click_button 'Archived'
      end

      click_button 'Update Target'
      dismiss_notification

      expect(page).to_not have_selector("div#target-show-#{target.id}")
      click_button 'Show Archived'
      expect(page).to have_selector("div#target-show-#{target.id}")
      expect(target.reload.visibility).to eq('archived')

      find('.target-group__target', text: target.title).click
      expect(page).to have_selector('.add-content-block--open', count: 1)
      click_button 'Next Step'

      within("div#evaluated") do
        click_button 'Yes'
      end

      expect(page).to have_text('Atleast one has to be selected')

      find("div[title='Select #{evaluation_criterion.name}']").click

      within("div#evaluated") do
        click_button 'No'
      end

      within("div#method_of_completion") do
        find('div', text: "Simply mark the target as completed.").click
      end

      within("div#visibility") do
        click_button 'Live'
      end

      click_button 'Update Target'
      dismiss_notification

      # Add few contents to target

      find('.target-group__target', text: target.title).click

      within('.add-content-block--open') do
        find('p', text: 'Markdown').click
      end

      replace_markdown(sample_markdown_text)
      find('span', text: 'Preview').click
      click_button 'Save'

      expect(page).to have_text('Content added successfully')
      dismiss_notification

      expect(target.content_versions.last.sort_index).to eq(1)
      expect(target.content_versions.last.content_block.block_type).to eq('markdown')

      within('.add-content-block--open') do
        find('p', text: 'Image').click
      end

      attach_file 'content_block[file]', file_path('pdf-sample.pdf'), visible: false
      click_button 'Save'

      expect(page).to have_text('File must be a JPEG, PNG, or GIF, less than 4096 pixels wide or high')
      dismiss_notification

      attach_file 'content_block[file]', file_path('logo_hackkar.png'), visible: false
      click_button 'Save'

      expect(page).to have_text('Content added successfully')
      dismiss_notification

      content_block = target.content_versions.reload.last.content_block
      expect(target.content_versions.reload.last.sort_index).to eq(2)
      expect(content_block.file.filename).to eq('logo_hackkar.png')

      within('.add-content-block--open') do
        find('p', text: 'File').click
      end

      attach_file 'content_block[file]', file_path('pdf-sample.pdf'), visible: false
      click_button 'Save'

      expect(page).to have_text('Content added successfully')
      dismiss_notification

      content_block = target.content_versions.reload.last.content_block
      expect(target.content_versions.last.sort_index).to eq(3)
      expect(content_block.file.filename).to eq('pdf-sample.pdf')

      within('.add-content-block--open') do
        find('p', text: 'Embed').click
      end

      fill_in 'Paste in a URL to embed', with: 'https://www.youtube.com/watch?v=3QDYbQIS8cQ'
      click_button 'Save'

      expect(page).to have_text('Content added successfully')
      dismiss_notification

      content_block = target.content_versions.reload.last.content_block
      expect(target.content_versions.last.sort_index).to eq(4)
      expect(content_block.block_type).to eq('embed')

      # Change target title
      expect(page).to_not have_selector(:button, 'Update')
      fill_in 'title', with: 'new target title', fill_options: { clear: :backspace }
      click_button 'Update'

      dismiss_notification

      expect(target.reload.title).to eq('new target title')
    end

    scenario 'modifies an existing target content' do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      target = target_5
      # Open the target editor
      find('.target-group__target', text: target.title).click
      click_button 'Edit'
      expect(page).to have_selector('.content-block__content', count: 4)
      find("div#add-block-1", visible: false).click

      within("div#content-type-picker-1") do
        find('p', text: 'Markdown').click
      end

      expect(page).to have_selector('.content-block__content', count: 5)

      replace_markdown(sample_markdown_text)
      find('span', text: 'Preview').click
      click_button 'Save'

      expect(page).to have_text('Content added successfully')
      dismiss_notification

      expect(target.reload.current_content_blocks.count).to eq(5)
      expect(latest_content_versions(target).pluck(:sort_index).sort).to eq([1, 2, 3, 4, 5])
      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'embed' }).last.sort_index).to eq(5)
      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'file' }).last.sort_index).to eq(4)

      # Move a block down
      within('#content-block-controls-1') do
        find_button('Move down').click
      end

      # Moving blocks has no message in the UI to be checked. Do some action before checking changes in DB
      within('#content-block-form-3') do
        find('span', text: 'Edit Markdown').click
        replace_markdown(sample_markdown_text)
        click_button 'Update'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'image' }).last.sort_index).to eq(1)
      expect(latest_content_versions(target).find_by(sort_index: 2).content_block.block_type).to eq('markdown')

      # Move a block up
      within('#content-block-controls-4') do
        find_button('Move down').click
      end

      within('#content-block-form-2') do
        find('span', text: 'Edit Markdown').click
        replace_markdown(sample_markdown_text)
        click_button 'Update'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'embed' }).last.sort_index).to eq(4)
      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'file' }).last.sort_index).to eq(5)

      # Update a file title
      within('#content-block-form-5') do
        fill_in 'content_block[title]', with: 'new file title', fill_options: { clear: :backspace }
        click_button 'Update Title'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'file' }).last.content_block.content['title']).to eq('new file title')

      # Update an image caption
      within('#content-block-form-1') do
        fill_in 'content_block[caption]', with: 'new image caption', fill_options: { clear: :backspace }
        click_button 'Update Caption'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      expect(latest_content_versions(target).joins(:content_block).where(content_blocks: { block_type: 'image' }).last.content_block.content['caption']).to eq('new image caption')

      # Delete few content block
      accept_confirm do
        within('#content-block-controls-1') do
          find_button('Delete block').click
        end
      end

      expect(page).to have_selector('.content-block__content', count: 4)
      expect(target.reload.current_content_blocks.find_by(block_type: 'image')).to eq(nil)
      expect(latest_content_versions(target).pluck(:sort_index).sort).to eq([1, 2, 3, 4])

      accept_confirm do
        within('#content-block-controls-2') do
          find_button('Delete block').click
        end
      end

      click_button 'Next Step'
      find('span', text: 'Add Content').click

      expect(page).to have_selector('.content-block__content', count: 3)
      expect(latest_content_versions(target).pluck(:sort_index).sort).to eq([1, 2, 3])
    end
  end

  context 'course author uses the curriculum editor' do
    scenario 'user can navigate only to assigned courses and modify content of those courses' do
      sign_in_user course_author.user, referer: curriculum_school_course_path(course)
      expect(page).to have_button(course.name)
      click_button course.name
      expect(page).to have_link(course_2.name, href: "/school/courses/#{course_2.id}/curriculum")
      expect(page).to_not have_link(course_3.name, href: "/school/courses/#{course_3.id}/curriculum")
      click_link course_2.name
      expect(page).to have_button(course_2.name)

      expect(page).to_not have_link(href: '/school/coaches')
      expect(page).to_not have_link(href: '/school/customize')
      expect(page).to_not have_link(href: '/school/courses')
      expect(page).to_not have_link(href: '/school/communities')
      expect(page).to have_link(href: '/home')

      [school_path, curriculum_school_course_path(course_3), school_communities_path, school_courses_path, customize_school_path].each do |path|
        visit path
        expect(page).to have_text("The page you were looking for doesn't exist!")
      end

      visit curriculum_school_course_path(course)
      find("#create-target-input#{target_group_2.id}").click
      fill_in "create-target-input#{target_group_2.id}", with: new_target_3_title
      click_button 'Create'

      expect(page).to have_text("Target created successfully")
      dismiss_notification

      click_button 'Next Step'
      expect(page).to have_text('Any prerequisite targets?')

      within("div#evaluated") do
        click_button 'No'
      end

      within("div#method_of_completion") do
        click_button 'Visit a link to complete the target.'
      end

      fill_in 'Link to complete', with: link_to_complete

      within("div#visibility") do
        click_button 'Live'
      end

      click_button 'Update Target'

      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      target = target_5
      # Open the target editor
      find('.target-group__target', text: target.title).click
      click_button 'Edit'
      expect(page).to have_selector('.content-block__content', count: 4)
      find("div#add-block-1", visible: false).click

      within("div#content-type-picker-1") do
        find('p', text: 'Markdown').click
      end

      expect(page).to have_selector('.content-block__content', count: 5)

      replace_markdown(sample_markdown_text)
      find('span', text: 'Preview').click
      click_button 'Save'

      expect(page).to have_text('Content added successfully')
      dismiss_notification

      # Move a block down
      within('#content-block-controls-1') do
        find_button('Move down').click
      end

      # Moving blocks has no message in the UI to be checked. Do some action before checking changes in DB
      within('#content-block-form-3') do
        find('span', text: 'Edit Markdown').click
        replace_markdown(sample_markdown_text)
        click_button 'Update'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      # Move a block up
      within('#content-block-controls-4') do
        find_button('Move down').click
      end

      within('#content-block-form-2') do
        find('span', text: 'Edit Markdown').click
        replace_markdown(sample_markdown_text)
        click_button 'Update'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      # Update a file title
      within('#content-block-form-5') do
        fill_in 'content_block[title]', with: 'new file title', fill_options: { clear: :backspace }
        click_button 'Update Title'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      # Update an image caption
      within('#content-block-form-1') do
        fill_in 'content_block[caption]', with: 'new image caption', fill_options: { clear: :backspace }
        click_button 'Update Caption'
      end

      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      # Delete a content block
      accept_confirm do
        within('#content-block-controls-1') do
          find_button('Delete block').click
        end
      end
    end
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit curriculum_school_course_path(course)
    expect(page).to have_text("Please sign in to continue.")
  end
end
