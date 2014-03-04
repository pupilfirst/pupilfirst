class V1::SessionsController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create]

  def create
    hash_string = "#{params[:timestamp]}#{Svapp::Application.config.secret_key_base}#{params[:email]}"
    # creating response
    @user = User.where("email = ?", params[:email]).first
    if not valid_request?(hash_string, params[:digest])
      render nothing: true, status: :unauthorized
    elsif @user.nil?
      render json: {success: false, user: nil}
    elsif not @user.valid_password?(params[:password])
      render json: {success: false, user: nil}
    else
      render :create
      # render json: {id: @user.id, auth_token: @user.auth_token}
    end
  end

private

  def valid_request?(hash_string, request_digest)
    Digest::SHA1.hexdigest(hash_string) == request_digest
  end

end
