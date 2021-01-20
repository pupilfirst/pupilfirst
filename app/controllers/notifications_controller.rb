class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    notification = current_user.notifications.find(params[:id])
    notification.touch(:read_at) if notification.read_at.blank? # rubocop:disable Rails/SkipsModelValidations

    path = Notifications::ResolvePathService.new(notification).resolve
    redirect_to(path)
  end
end
