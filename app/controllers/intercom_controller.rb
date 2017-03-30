class IntercomController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :user_create

  # POST /intercom_user_create
  #
  # webhook url for stripping off user_id from new intercom users
  def user_create
    raise 'Unexpected Intercom Webhook Topic' unless params[:topic] == 'user.created'

    email = params.dig(:data, :item, :email)
    raise 'Could not retrieve email from Webhook POST' if email.blank?

    IntercomClient.new.strip_user_id(email)
    head :ok
  end
end
