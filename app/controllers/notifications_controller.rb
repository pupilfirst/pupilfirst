class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    notification = current_user.notifications.find(params[:id])
    notification.touch(:read_at) if notification.read_at.blank? # rubocop:disable Rails/SkipsModelValidations

    path = Notifications::ResolvePathService.new(notification).resolve
    redirect_to(path)
    # case notification.notifiable_type
    #   when 'Topic'
    #     redirect_to topic_path(notification.notifiable_id)
    #   else
    #     redirect_to dashboard_path
    # end
  end
end
