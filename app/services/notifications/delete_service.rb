module Notifications
  class DeleteService
    def initialize(notifiable)
      @notifiable = notifiable
    end

    def execute
      Notification.where(notifiable: @notifiable).destroy_all
    end
  end
end
