require 'rails_helper'

feature 'Notification Show Spec', js: true do
  include UserSpecHelper
  include WithEnvHelper
  let(:student) { create :student }
  let(:vapid_key) { Webpush.generate_key }

  let(:env_vars) {
    {
      VAPID_PUBLIC_KEY: vapid_key.public_key,
      VAPID_PRIVATE_KEY: vapid_key.private_key
    }
  }

  around do |example|
    with_env(env_vars) do
      example.run
    end
  end

  context 'with few notifications' do
    let!(:notification_1) { create :notification, recipient: student.user }
    let!(:notification_2) { create :notification, recipient: student.user }
    let!(:notification_3) { create :notification, :read, recipient: student.user }
    let!(:notification_4) { create :notification, :read, recipient: student.user }

    scenario 'user plays around with search' do
      sign_in_user student.user, referrer: dashboard_path
      click_button 'Show Notifications'

      expect(page).to have_text(notification_1.message)
      expect(page).not_to have_text(notification_4.message)

      fill_in('Search', with: 'Read')
      click_button 'Pick Status: Read'

      expect(page).not_to have_text(notification_1.message)
      expect(page).not_to have_text(notification_2.message)
      expect(page).to have_text(notification_3.message)
      expect(page).to have_text(notification_4.message)

      fill_in('Search', with: 'Unread')
      click_button 'Pick Status: Unread'

      expect(page).not_to have_text(notification_3.message)
      expect(page).not_to have_text(notification_4.message)
      expect(page).to have_text(notification_1.message)
      expect(page).to have_text(notification_2.message)

      fill_in('Search', with: notification_3.message)
      click_button "Pick Search by title: #{notification_3.message}"
      expect(page).to have_text("You don't have any notifications!")

      click_button 'Remove selection: Unread'

      within("div[id='entries']") do
        expect(page).to have_text(notification_3.message)
      end
    end

    scenario 'user marks a notification as read' do
      sign_in_user student.user, referrer: dashboard_path
      click_button 'Show Notifications'

      expect(page).to have_text(notification_1.message)

      find("div[aria-label='Notification #{notification_1.id}']").hover
      within("div[aria-label='Notification #{notification_1.id}']") do
        click_button 'Mark as Read'
      end

      expect(page).not_to have_text(notification_1.message)
      expect(notification_1.reload.read_at).not_to eq(nil)
    end

    scenario 'user mark all notifications as read' do
      sign_in_user student.user, referrer: dashboard_path
      click_button 'Show Notifications'

      click_button 'Mark All as Read'

      expect(page).to have_text("You don't have any notifications!")
      expect(Notification.where.not(read_at: nil)).not_to eq([])
    end
  end

  context 'with many notifications' do
    before do
      25.times do
        create :notification, recipient: student.user
      end
    end

    scenario 'user loads all notifications' do
      sign_in_user student.user, referrer: dashboard_path
      click_button 'Show Notifications'

      expect(page).to have_text('Showing 10 of 25 notifications')
      click_button 'Load More Notifications...'

      expect(page).to have_text('Showing 20 of 25 notifications')
      click_button 'Load More Notifications...'

      expect(page).to have_text('Showing all 25 notifications')
      expect(page).not_to have_text('Load More Notifications...')
    end
  end

  scenario 'When an user visits for the first time' do
    sign_in_user student.user, referrer: dashboard_path

    click_button 'Show Notifications'
    expect(page).to have_text("You don't have any notifications!")
  end

  scenario 'Subscribes for notifications' do

    sign_in_user student.user, referrer: dashboard_path

    click_button 'Show Notifications'
    expect(page).to have_text("Subscribe")
  end
end
