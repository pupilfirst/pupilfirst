module NotificationHelper
  def dismiss_notification
    find('.ui-pnotify-container', match: :first).click
    expect(page).not_to have_selector('.ui-pnotify-container')
  end
end
