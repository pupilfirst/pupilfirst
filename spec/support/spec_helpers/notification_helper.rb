module NotificationHelper
  def dismiss_notification
    find('.ui-pnotify-container').click
    expect(page).not_to have_selector('.ui-pnotify-container')
  end
end
