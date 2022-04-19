module NotificationHelper
  def dismiss_notification
    container_class = '.pnotify'
    expect(page).to have_selector(container_class)
    page.execute_script("document.querySelector('#{container_class}').click()")
    expect(page).not_to have_selector(container_class)
  end
end
