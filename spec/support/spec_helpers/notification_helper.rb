module NotificationHelper
  def dismiss_notification
    container_class = '.ui-pnotify-container'
    expect(page).to have_selector(container_class)
    page.execute_script("document.querySelector('#{container_class}').click()")
    expect(page).not_to have_selector(container_class)
  end
end
