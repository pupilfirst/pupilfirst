require 'rails_helper'

feature 'Target Content Version Management', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper
  include ActiveSupport::Testing::TimeHelpers

  # Setup a course with few targets to modify content
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:level_1) { create :level, :one, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_1) { create :target, :with_content, target_group: target_group_1 }
  let!(:target_2) { create :target, target_group: target_group_1 }
  let(:sample_markdown_text) { Faker::Markdown.sandwich(6) }

  # Create few content blocks for target_1
  let!(:cb_1) { create :content_block, :markdown, created_at: 3.days.ago }
  let!(:cb_2) { create :content_block, :embed, created_at: 3.days.ago }

  let!(:cb_3) { create :content_block, :file, created_at: 2.days.ago }

  before do
    stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=3QDYbQIS8cQ').to_return(body: '{"version":"1.0","provider_name":"YouTube","html":"\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e","thumbnail_url":"https:\/\/i.ytimg.com\/vi\/3QDYbQIS8cQ\/hqdefault.jpg","provider_url":"https:\/\/www.youtube.com\/","thumbnail_height":360,"type":"video","height":270,"thumbnail_width":480,"author_url":"https:\/\/www.youtube.com\/channel\/UCvsvW3QH1700y-j2VfEnq-A","author_name":"Just smile","title":"Funny And Cute Cats - Funniest Cats Compilation 2019","width":480}', status: 200) # rubocop:disable Metrics/LineLength
  end

  def file_path(filename)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'files', filename))
  end

  def latest_content_versions(target)
    target.content_versions.reload.where(version_on: target.latest_content_version_date)
  end

  def format_date(date)
    date.strftime("#{date.day.ordinalize} %b %Y")
  end

  context 'admin modifies content of a target with content' do
    before do
      sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

      # Create couple of old content versions for target 1
      travel_to 3.days.ago do
        target_1.content_versions.create!(content_block: cb_1, version_on: Date.today, sort_index: 1)
        target_1.content_versions.create!(content_block: cb_2, version_on: Date.today, sort_index: 2)
      end

      travel_to 2.days.ago do
        target_1.content_versions.create!(content_block: cb_3, version_on: Date.today, sort_index: 1)
      end
    end

    scenario 'modifies content today' do
      expect(page).to have_text(target_1.title)
      find('.target-group__target', text: target_1.title).click
      expect(page).to_not have_selector('.add-content-block--open', count: 1)
      # Check the version management buttons
      expect(page).to have_button(format_date(Date.today))
      click_button format_date(Date.today)
      expect(page).to have_text(format_date(2.days.ago))
      expect(page).to have_text(format_date(3.days.ago))
      click_button format_date(Date.today)
      click_button 'Edit'
      expect(page).to have_selector('.add-content-block--open', count: 1)

      # Update a content block
      within('#content-block-form-4') do
        fill_in 'content_block[title]', with: 'new file title', fill_options: { clear: :backspace }
        click_button 'Update Title'
      end
      expect(page).to have_text('Content updated successfully')
      dismiss_notification

      target_content_versions = target_1.content_versions.reload
      expect(target_content_versions.where(version_on: Date.today).count).to eq(4)
      expect(target_content_versions.where(version_on: 2.days.ago).count).to eq(1)
      expect(target_content_versions.where(version_on: 3.days.ago).count).to eq(2)
      expect(target_content_versions.count).to eq(7)

      # Create a content block
      find("div#add-block-3", visible: false).click
      within("div#content-type-picker-3") do
        find('p', text: 'Markdown').click
      end
      replace_markdown(sample_markdown_text)
      find('span', text: 'Preview').click
      click_button 'Save'
      expect(page).to have_text('Content added successfully')
      dismiss_notification

      target_content_versions = target_1.content_versions.reload
      expect(target_content_versions.count).to eq(8)
      expect(target_content_versions.last.sort_index).to eq(3)
      expect(target_content_versions.last.content_block.block_type).to eq('markdown')
      expect(target_content_versions.where(version_on: Date.today).pluck(:sort_index).sort).to eq([1, 2, 3, 4, 5])

      # Delete a content block
      cb_id_to_delete = target_content_versions.where(version_on: Date.today, sort_index: 2).first.content_block_id
      accept_confirm do
        within('#content-block-controls-2') do
          find_button('Delete block').click
        end
      end
      expect(page).to have_selector('.content-block__content', count: 4)

      target_content_versions = target_1.content_versions.reload
      expect(target_content_versions.count).to eq(7)
      expect(target_content_versions.where(content_block_id: cb_id_to_delete).count).to eq(0)
      expect(ContentBlock.where(id: cb_id_to_delete).count).to eq(0)
      expect(target_content_versions.where(version_on: Date.today).pluck(:sort_index).sort).to eq([1, 2, 3, 4])

      # Update content sorting
      current_cb_sorting = target_content_versions.where(version_on: Date.today).order(:sort_index).pluck(:content_block_id)

      within('#content-block-controls-3') do
        find_button('Move down').click
      end

      expect(page).to have_selector('.content-block__content', count: 4)
      sleep 3
      expect(target_1.content_versions.reload.where(version_on: Date.today).order(:sort_index).pluck(:content_block_id)).to eq([current_cb_sorting[0], current_cb_sorting[2], current_cb_sorting[1], current_cb_sorting[3]])
      expect(target_1.latest_content_versions.count).to eq(4)
    end

    scenario 'modifies content on a future date' do
      travel_to 2.days.from_now do
        expect(page).to have_text(target_1.title)
        find('.target-group__target', text: target_1.title).click
        expect(page).to_not have_selector('.add-content-block--open', count: 1)
        # Check the version management buttons
        expect(page).to have_button(format_date(2.days.ago))
        click_button format_date(2.days.ago)
        expect(page).to have_text(format_date(4.days.ago))
        expect(page).to have_text(format_date(5.days.ago))
        click_button format_date(2.days.ago)
        click_button 'Edit'
        expect(page).to have_selector('.add-content-block--open', count: 1)

        # Update a content block
        block_to_update = target_1.content_versions.where(sort_index: 4).first.content_block
        within('#content-block-form-4') do
          fill_in 'content_block[title]', with: 'new file title', fill_options: { clear: :backspace }
          click_button 'Update Title'
        end
        expect(page).to have_text('Content updated successfully')
        dismiss_notification

        target_content_versions = target_1.content_versions.reload
        expect(block_to_update.id).to_not eq(target_1.latest_content_versions.where(sort_index: 4).first.content_block_id)
        expect(target_content_versions.where(version_on: Date.today).count).to eq(4)
        expect(target_content_versions.where(version_on: 2.days.ago).count).to eq(4)
        expect(target_content_versions.where(version_on: 5.days.ago).count).to eq(2)
        expect(target_content_versions.where(version_on: 4.days.ago).count).to eq(1)
        expect(target_content_versions.count).to eq(11)

        # Create a content block
        find("div#add-block-3", visible: false).click
        within("div#content-type-picker-3") do
          find('p', text: 'Markdown').click
        end
        replace_markdown(sample_markdown_text)
        find('span', text: 'Preview').click
        click_button 'Save'
        expect(page).to have_text('Content added successfully')
        dismiss_notification

        expect(target_content_versions.where(version_on: Date.today).count).to eq(5)
        expect(target_content_versions.count).to eq(12)
        expect(ContentVersion.last.sort_index).to eq(3)

        # Delete the block created today
        cb_id_to_delete = target_1.latest_content_versions.where(sort_index: 3).first.content_block_id
        accept_confirm do
          within('#content-block-controls-3') do
            find_button('Delete block').click
          end
        end
        expect(page).to have_selector('.content-block__content', count: 4)
        target_1.content_versions.reload
        expect(target_1.latest_content_versions.count).to eq(4)
        expect(ContentBlock.find_by(id: cb_id_to_delete)).to eq(nil)
        expect(target_content_versions.count).to eq(11)

        # Delete an old content block
        cb_id_to_delete = target_1.latest_content_versions.where(sort_index: 2).first.content_block_id
        accept_confirm do
          within('#content-block-controls-2') do
            find_button('Delete block').click
          end
        end
        expect(page).to have_selector('.content-block__content', count: 3)
        target_1.content_versions.reload
        expect(target_1.latest_content_versions.count).to eq(3)
        # the content block should not be destroyed
        expect(ContentBlock.find_by(id: cb_id_to_delete)).to_not eq(nil)
        expect(target_1.content_versions.count).to eq(10)

        # # Change content block sorting
        # within('#content-block-controls-1') do
        #   find_button('Move down').click
        # end
        # sleep 2
        # expect(page).to have_selector('.content-block__content', count: 3)
        # within('#content-block-form-1') do
        #   expect(page).to have_button('Update Caption')
        # end
        # target_1.content_versions.reload
        # expect(target_1.latest_content_versions.count).to eq(3)
        # expect(target_1.latest_content_versions.where(sort_index: 2).first.content_block.block_type).to eq('embed')
        # expect(target_1.latest_content_versions.where(sort_index: 1).first.content_block.block_type).to eq('image')
      end
    end

    scenario 'restores to an old version' do
      # View an old version of the target
      find('.target-group__target', text: target_1.title).click
      expect(page).to have_button('Edit')
      expect(page).to_not have_selector('.add-content-block--open', count: 1)

      click_button format_date(Date.today)
      expect(page).to have_text(format_date(3.days.ago))
      expect(page).to have_selector('.target-editor__version-dropdown-list-item', count: 2)
      find('#version-selection-list').find('li', text: format_date(3.days.ago)).click
    end
  end
end
