module DevelopersNotificationsHelper
  def prepare_developers_notification
    notification_service = instance_double('Developers::NotificationService')
    allow(notification_service).to receive(:execute).with(
      an_instance_of(Course),
      kind_of(Symbol),
      an_instance_of(User),
      kind_of(ApplicationRecord)
    )
    allow(Developers::NotificationService).to receive(:new).and_return(notification_service)
    notification_service
  end

  def expect_published(notification_service, course, event_type, actor, resource)
    expect(notification_service).to have_received(:execute).with(
      course,
      event_type,
      actor,
      resource
    )
  end
end
