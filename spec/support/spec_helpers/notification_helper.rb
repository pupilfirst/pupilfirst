module NotificationHelper
  def dismiss_notification
    container_class = ".pnotify"
    # Wait until the notifications are present
    expect(page).to have_selector(container_class)

    # Find all notifications and iterate over them
    page
      .all(container_class)
      .each do |notification|
        notification.click
        # Wait for the notification to disappear after clicking
        expect(notification).not_to be_visible
      end

    # Verify that no notifications are present after handling all
    expect(page).not_to have_selector(container_class)
  end
end
