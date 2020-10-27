require 'rails_helper'

feature 'Markdown editor', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include SampleFilesHelper

  # Setup a course with students and target for community.
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }

  let!(:community) { create :community, school: school, target_linkable: true }
  let(:team) { create :team, level: level_1 }
  let(:student) { create :student, startup: team }

  before do
    create :community_course_connection, course: course, community: community
  end

  let(:intro_sentence) { Faker::Lorem.sentence }

  scenario 'user uploads an image and a PDF' do
    sign_in_user(student.user, referrer: new_topic_community_path(community))

    expect(page).to have_text('Create a new topic')

    fill_in 'Title', with: 'This is a title.'
    add_markdown(intro_sentence)
    attach_file("Click here to attach a file.", sample_file_path('logo_lipsum_on_light_bg.png'), visible: false)

    expect(page).to have_text('logo_lipsum_on_light_bg.png')

    # Add a bit of sleep here to allow the JS to fully insert the markdown embed code.
    sleep(0.1)

    attach_file("Click here to attach a file.", sample_file_path('pdf-sample.pdf'), visible: false)

    expect(page).to have_text('pdf-sample.pdf')

    # Both attachments should not have been accessed at this point.
    expect(MarkdownAttachment.where(last_accessed_at: nil).count).to eq(2)

    click_button('Create Topic')
    expect(page).to have_text('0 Replies')

    # Let's check if the saved markdown is what we expect...

    last_topic = Topic.last
    image_attachment = MarkdownAttachment.first
    pdf_attachment = MarkdownAttachment.last

    expect(last_topic.first_post.body).to include("#{intro_sentence}\n![logo_lipsum_on_light_bg.png]")

    expected_url_head = "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/markdown_attachments"

    expect(last_topic.first_post.body).to match(
      %r{!\[logo_lipsum_on_light_bg\.png\]\(#{expected_url_head}/#{image_attachment.id}/#{image_attachment.token}\)}
    )

    # Make sure the token _looks_ right.
    expect(image_attachment.token).to match(/[a-zA-Z0-9\-_]{22}/)

    expect(last_topic.first_post.body).to include("\n[pdf-sample.pdf]")

    expect(last_topic.first_post.body).to match(
      %r{\[pdf-sample\.pdf\]\(#{expected_url_head}/#{pdf_attachment.id}/#{pdf_attachment.token}\)}
    )

    # The attachment should have been linked to the uploading user.
    expect(image_attachment.user).to eq(student.user)
    expect(pdf_attachment.user).to eq(student.user)

    # The image attachment should have been accessed at this point.
    expect(MarkdownAttachment.where(last_accessed_at: nil).count).to eq(1)
    expect(image_attachment.last_accessed_at).to be_present
  end

  context 'when the user has already attached a lot of files today' do
    around do |example|
      original_value = Rails.application.secrets.max_daily_markdown_attachments
      Rails.application.secrets.max_daily_markdown_attachments = 1

      example.run

      Rails.application.secrets.max_daily_markdown_attachments = original_value
    end

    scenario 'user exceeds daily attachment limit' do
      sign_in_user(student.user, referrer: new_topic_community_path(community))
      fill_in 'Title', with: 'This is a title.'

      attach_file("Click here to attach a file.", sample_file_path('logo_lipsum_on_light_bg.png'), visible: false)

      expect(page).to have_text('logo_lipsum_on_light_bg.png')

      click_button('Create Topic')
      expect(page).to have_text('0 Replies')

      # Let's try filling in an reply with an attachment.
      attach_file("Click here to attach a file.", sample_file_path('pdf-sample.pdf'), visible: false)

      expect(page).to have_text('You have exceeded the number of attachments allowed per day.')
      expect(page).not_to have_text('logo_lipsum_on_light_bg.png')

      expect(MarkdownAttachment.count).to eq(1)
    end
  end
end
