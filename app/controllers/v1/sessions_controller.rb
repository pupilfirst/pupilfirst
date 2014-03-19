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
      render json: {error: "No user found with that email/password"}, status: :bad_request
    elsif not @user.valid_password?(params[:password])
      render json: {error: "No user found with that email/password"}, status: :bad_request
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
