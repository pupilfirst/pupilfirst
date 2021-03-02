module DevelopersNotifications
  def publish(course, event_type, actor, resource)
    notification_service.execute(course, event_type, actor, resource)
  end

  private

  def notification_service
    Developers::NotificationService.new
  end
end
