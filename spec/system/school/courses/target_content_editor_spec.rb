require 'rails_helper'

feature 'Target Content Editor', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:faculty) { create :faculty, school: school }
  let!(:course_author) { create :course_author, course: course, user: faculty.user }
  let!(:level_1) { create :level, :one, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target) { create :target, :with_file, target_group: target_group_1 }

  def file_path(filename)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'files', filename))
  end

  scenario 'school admin adds and edits a markdown block' do
    sign_in_user school_admin.user, referrer: curriculum_school_course_path(course)

    # Open the content editor for the target.
    find("a[title='Edit content of target #{target.title}']").click

    expect(target.target_versions.count).to eq(1)
    expect(target.current_target_version.content_blocks.count).to eq(1)

    # Try adding a new markdown block.
    within('.content-block-creator--open') do
      find('p', text: 'Markdown').click
    end

    expect(page).to have_selector('textarea[aria-label="Markdown editor"]')
    expect(target.current_target_version.content_blocks.count).to eq(2)

    cb = ContentBlock.last

    expect(cb.block_type).to eq(ContentBlock::BLOCK_TYPE_MARKDOWN)
    expect(cb.content).to eq('markdown' => '')

    # There should be no save changes button right now.
    expect(page).not_to have_selector("button[title='Save Changes']")

    # Let's try setting some text in the markdown block.
    first_sentence = Faker::Lorem.sentence
    add_markdown(first_sentence)

    # Changing view should be confirmed.
    dismiss_confirm { find('button[title="Close Editor"').click }
    dismiss_confirm { click_link 'Details' }

    find("button[title='Save Changes']").click

    expect(page).not_to have_selector("button[title='Save Changes']")
    expect(cb.reload.content).to eq('markdown' => first_sentence)

    # Try changing the text in the markdown block and then undo-ing changes.
    replace_markdown(Faker::Lorem.sentence)

    expect(page).to have_selector("button[title='Save Changes']")

    accept_confirm do
      find("button[title='Undo Changes']").click
    end

    expect(page).not_to have_selector("button[title='Save Changes']")
    expect(page).not_to have_selector("button[title='Undo Changes']")
    expect(page).to have_selector('textarea', text: first_sentence)

    second_sentence = "\n\n" + Faker::Lorem.sentence
    add_markdown(second_sentence)
    find("button[title='Save Changes']").click

    expect(page).not_to have_selector("button[title='Save Changes']")
    expect(cb.reload.content).to eq('markdown' => first_sentence + second_sentence)
  end

  scenario 'school admin adds and edits an image block' do
    sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

    expect(target.current_target_version.content_blocks.count).to eq(1)

    filename = 'logo_lipsum_on_light_bg.png'

    # Try adding a new image block.
    within('.content-block-creator--open') do
      page.attach_file(file_path(filename)) do
        find('p', text: 'Image').click
      end
    end

    dismiss_notification

    expect(page).to have_text(filename)
    expect(target.current_target_version.content_blocks.count).to eq(2)
    expect(page).not_to have_selector("button[title='Save Changes']")

    cb = ContentBlock.last
    expect(cb.block_type).to eq(ContentBlock::BLOCK_TYPE_IMAGE)
    expect(cb.content['caption']).to eq(filename)

    # Try changing the caption and width.
    new_caption = Faker::Lorem.sentence
    fill_in 'Caption', with: new_caption
    find('.image-block-editor__container').hover
    find('button[title="Three-fifths width"]').click

    # Changing view should be confirmed.
    dismiss_confirm { find('button[title="Close Editor"').click }
    dismiss_confirm { click_link 'Versions' }

    find("button[title='Save Changes']").click

    expect(page).not_to have_selector("button[title='Save Changes']")
    expect(cb.reload.content['caption']).to eq(new_caption)
    expect(cb.content['width']).to eq('ThreeFifths')

    # Try the undo button.
    fill_in 'Caption', with: Faker::Lorem.sentence

    accept_confirm do
      find("button[title='Undo Changes']").click
    end

    expect(page).not_to have_selector("button[title='Undo Changes']")
    expect(page).to have_selector("input[value='#{new_caption}'")
  end

  scenario 'school admin adds and edits a file block' do
    sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

    expect(target.current_target_version.content_blocks.count).to eq(1)

    filename = 'pdf-sample.pdf'

    # Try adding a new file block.
    within('.content-block-creator--open') do
      page.attach_file(file_path(filename)) do
        find('p', text: 'File').click
      end
    end

    dismiss_notification
    expect(page).to have_text(filename)
    expect(target.current_target_version.content_blocks.count).to eq(2)
    expect(page).not_to have_selector("button[title='Save Changes']")

    cb = ContentBlock.last
    expect(cb.block_type).to eq(ContentBlock::BLOCK_TYPE_FILE)
    expect(cb.content).to eq('title' => filename)

    # Try changing the caption.
    new_title = Faker::Lorem.words(number: 3).join(' ')

    within("div[aria-label='Editor for content block #{cb.id}']") do
      fill_in 'Title', with: new_title
    end

    # Closing editor should be confirmed.
    dismiss_confirm { find('button[title="Close Editor"').click }

    within("div[aria-label='Editor for content block #{cb.id}']") do
      find("button[title='Save Changes']").click

      expect(page).not_to have_selector("button[title='Save Changes']")

      expect(cb.reload.content).to eq('title' => new_title)

      # Try the undo button.
      fill_in 'Title', with: Faker::Lorem.words(number: 3).join(' ')

      accept_confirm do
        find("button[title='Undo Changes']").click
      end
      expect(page).not_to have_selector("button[title='Undo Changes']")
      expect(page).to have_selector("input[value='#{new_title}'")
    end
  end

  scenario 'school admin adds an embed block' do
    sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

    expect(target.current_target_version.content_blocks.count).to eq(1)
    expect(page).to have_selector('button[title="Delete"]', count: 0) # There is only one block - so the button should be hidden.

    embed_url = 'https://www.youtube.com/watch?v=3QDYbQIS8cQ'

    stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=3QDYbQIS8cQ')
      .to_return(body: '{"version":"1.0","provider_name":"YouTube","html":"\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e","thumbnail_url":"https:\/\/i.ytimg.com\/vi\/3QDYbQIS8cQ\/hqdefault.jpg","provider_url":"https:\/\/www.youtube.com\/","thumbnail_height":360,"type":"video","height":270,"thumbnail_width":480,"author_url":"https:\/\/www.youtube.com\/channel\/UCvsvW3QH1700y-j2VfEnq-A","author_name":"Just smile","title":"Funny And Cute Cats - Funniest Cats Compilation 2019","width":480}', status: 200)

    # Try adding a new file block.
    within('.content-block-creator--open') do
      find('p', text: 'Embed').click
      fill_in('URL to Embed', with: embed_url)
      click_button('Save')
    end
    expect(page).to have_selector('button[title="Delete"]', count: 2)
    expect(target.current_target_version.content_blocks.count).to eq(2)

    cb = ContentBlock.last

    expect(cb.block_type).to eq(ContentBlock::BLOCK_TYPE_EMBED)
    expect(cb.content['url']).to eq(embed_url)
    expect(cb.content['embed_code']).to be_present
  end

  scenario 'school admin adds an invalid embed block' do
    sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

    embed_url = 'https://www.youtube.com/watch?v=INVALID_ID'

    stub_request(:get, "https://www.youtube.com/oembed?format=json&url=#{embed_url}")
      .to_return(body: '')

    # Try adding a new embed block.
    within('.content-block-creator--open') do
      find('p', text: 'Embed').click
      fill_in('URL to Embed', with: embed_url)
      click_button('Save')
    end

    expect(page).to have_text("Unable to embed, retrying in 1 minute")

    cb = ContentBlock.last
    expect(cb.block_type).to eq(ContentBlock::BLOCK_TYPE_EMBED)
    expect(cb.content['url']).to eq(embed_url)
    expect(cb.content['embed_code']).to eq(nil)
    expect(cb.content['last_resolved_at']).to be_present
    expect(cb.content['request_source']).to eq('User')
  end

  context 'when video upload is enabled for a school' do
    let(:vimeo_access_token) { SecureRandom.hex }
    let(:title) { Faker::Lorem.words(number: 3).join(' ') }
    let(:description) { Faker::Lorem.words(number: 10).join(' ') }

    let!(:request_headers) do
      {
        'Accept' => 'application/vnd.vimeo.*+json;version=3.4',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => "Bearer #{vimeo_access_token}",
        'Content-Type' => 'application/json',
        'Host' => 'api.vimeo.com',
        'User-Agent' => 'Ruby'
      }
    end

    let!(:request_body) do
      {
        'uri' => '/videos/123456789',
        'link' => 'https://vimeo.com/123456789',
        'upload' => { 'upload_link' => 'https://vimeo.com/123456789/upload' }
      }
    end

    let!(:account_type) { %w[basic pro].sample }

    before do
      school.configuration['vimeo'] = { access_token: vimeo_access_token, account_type: account_type }
      school.save!

      stub_request(:post, 'https://api.vimeo.com/me/videos/')
        .with(
          body: "{\"upload\":{\"approach\":\"tus\",\"size\":588563},\"privacy\":{\"embed\":\"whitelist\",\"view\":\"#{account_type == 'basic' ? 'anybody' : 'disable'}\"},\"embed\":{\"buttons\":{\"like\":false,\"watchlater\":false,\"share\":false},\"logos\":{\"vimeo\":false},\"title\":{\"name\":\"show\",\"owner\":\"hide\",\"portrait\":\"hide\"}},\"name\":\"#{title}\",\"description\":\"#{description}\"}",
          headers: request_headers
        ).to_return(status: 200, body: request_body.to_json, headers: {})

      stub_request(:put, "https://api.vimeo.com/videos/123456789/privacy/domains/test.host/").with(body: "{}", headers: request_headers).to_return(status: 200, body: "", headers: {})
      stub_request(:get, "https://vimeo.com/api/oembed.json?url=https://vimeo.com/123456789").to_return(body: '')
    end

    scenario 'school admin uploads a video' do
      sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

      within('.content-block-creator--open') do
        find('p', text: 'Video').click

        # Try uploading an image
        filename_image = 'pdf-sample.pdf'
        page.attach_file(file_path(filename_image)) do
          find('label', text: 'Select File and Upload').click
        end

        expect(page).to have_text('Invalid file format, please select an MP4, MOV, WMV or AVI file')

        # Upload a video
        fill_in 'Title', with: title
        fill_in 'Description', with: description

        filename_video = 'pupilfirst-logo.mp4'
        page.attach_file(file_path(filename_video)) do
          find('label', text: 'Select File and Upload').click
        end
      end

      expect(page).to have_text("https://vimeo.com/123456789")
      expect(target.current_target_version.content_blocks.count).to eq(2)

      cb = ContentBlock.last
      expect(cb.block_type).to eq(ContentBlock::BLOCK_TYPE_EMBED)
      expect(cb.content['embed_code']).to eq(nil)
      expect(cb.content['last_resolved_at']).to be_present
      expect(cb.content['request_source']).to eq('VimeoUpload')
    end

    scenario 'course author uploads a video' do
      sign_in_user course_author.user, referrer: content_school_course_target_path(course, target)

      within('.content-block-creator--open') do
        find('p', text: 'Video').click
        fill_in 'Title', with: title
        fill_in 'Description', with: description

        page.attach_file(file_path('pupilfirst-logo.mp4')) do
          find('label', text: 'Select File and Upload').click
        end
      end

      expect(page).to have_text("https://vimeo.com/123456789")
    end
  end

  context 'when a target has many content blocks' do
    let!(:target) { create :target, target_group: target_group_1 }
    let!(:target_version) { create(:target_version, target: target) }
    let!(:first_block) { create(:content_block, :image, target_version: target_version, sort_index: 0) }
    let!(:second_block) { create(:content_block, :markdown, target_version: target_version, sort_index: 1) }
    let!(:third_block) { create(:content_block, :file, target_version: target_version, sort_index: 2) }
    let!(:fourth_block) { create(:content_block, :file, target_version: target_version, sort_index: 3) }

    scenario 'school admin changes the sort order of existing content blocks' do
      sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

      # The first block should only have the "move down" button.
      within("div[aria-label='Editor for content block #{first_block.id}'") do
        expect(page).to have_selector("button[title='Move Down']")
        expect(page).not_to have_selector("button[title='Move Up']")
      end

      # Blocks in the middle should have both buttons.
      [second_block, third_block].each do |block|
        within("div[aria-label='Editor for content block #{block.id}'") do
          expect(page).to have_selector("button[title='Move Up']")
          expect(page).to have_selector("button[title='Move Down']")
        end
      end

      # The last block should only have the "move up" button.
      within("div[aria-label='Editor for content block #{fourth_block.id}'") do
        expect(page).to have_selector("button[title='Move Up']")
        expect(page).not_to have_selector("button[title='Move Down']")
      end

      # The second block, moved up, should lose the "move up" button.
      within("div[aria-label='Editor for content block #{second_block.id}'") do
        find("button[title='Move Up']").click
        sleep(0.1)
        expect(page).not_to have_selector("button[title='Move Up']")
      end

      # The second last block, moved down, should lose the "move down" button.
      within("div[aria-label='Editor for content block #{third_block.id}'") do
        find("button[title='Move Down']").click
        sleep(0.1)
        expect(page).not_to have_selector("button[title='Move Down']")
      end

      sleep(0.1)

      expect(second_block.reload.sort_index).to eq(0)
      expect(first_block.reload.sort_index).to eq(1)
      expect(fourth_block.reload.sort_index).to eq(2)
      expect(third_block.reload.sort_index).to eq(3)
    end

    scenario 'admin deletes an existing content block' do
      sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

      expect(page).to have_selector('button[title="Delete"]', count: 4)

      # The reason this sleep is necessary is unknown. But without it, the delete click will not work properly.
      sleep 0.1

      within("div[aria-label='Editor for content block #{first_block.id}']") do
        accept_confirm do
          find('button[title="Delete"]').click
        end
      end

      expect(page).to have_selector('button[title="Delete"]', count: 3)
      expect(TargetVersion.count).to eq(1)
      expect(TargetVersion.first.content_blocks.pluck(:id)).not_to include(first_block.id)
      expect(ContentBlock.count).to eq(3)
    end
  end

  scenario 'course author edits the content of a target' do
    # This is a quick and incomplete test that checks access to this interface.
    sign_in_user course_author.user, referrer: content_school_course_target_path(course, target)

    first_block = ContentBlock.first

    # Try editing the title of the existing file block.
    new_title = Faker::Lorem.words(number: 3).join(' ')

    within("div[aria-label='Editor for content block #{first_block.id}']") do
      fill_in 'Title', with: new_title
      find("button[title='Save Changes']").click
    end

    expect(page).not_to have_selector("button[title='Save Changes']")
    expect(first_block.reload.content).to eq('title' => new_title)

    # Try adding a new markdown block.
    within('.content-block-creator--open') do
      find('p', text: 'Markdown').click
    end

    expect(page).to have_selector('textarea[aria-label="Markdown editor"]')
    expect(ContentBlock.order(created_at: :desc).first.content).to eq('markdown' => '')

    window = window_opened_by { click_link 'View as Student' }

    within_window window do
      expect(page).to have_content('You are currently looking at a preview of this course')
    end
  end

  scenario 'admin is warned before switching tabs or closing the editor when there are unsaved changes' do
    sign_in_user school_admin.user, referrer: content_school_course_target_path(course, target)

    first_block = ContentBlock.first
    new_title = Faker::Lorem.words(number: 3).join(' ')

    expect(page).to have_selector("div[aria-label='Editor for content block #{first_block.id}']")

    # Without changes, closing editor or changing tab should not be confirmed.
    click_link 'Details'
    expect(page).to have_text('Will a coach review submissions on this target?')
    click_link 'Content'
    expect(page).to have_selector("div[aria-label='Editor for content block #{first_block.id}']")
    find('button[title="Close Editor"').click
    expect(page).not_to have_selector("div[aria-label='Editor for content block #{first_block.id}']")
    find("a[title='Edit content of target #{target.title}']").click

    # With changes, navigation away from content editor should be confirmed.
    within("div[aria-label='Editor for content block #{first_block.id}']") do
      fill_in 'Title', with: new_title
    end

    accept_confirm do
      click_link 'Details'
    end

    expect(page).to have_text('Will a coach review submissions on this target?')

    click_link 'Content'

    within("div[aria-label='Editor for content block #{first_block.id}']") do
      fill_in 'Title', with: new_title
    end

    accept_confirm do
      find('button[title="Close Editor"').click
    end

    expect(page).not_to have_selector("div[aria-label='Editor for content block #{first_block.id}']")
  end
end
