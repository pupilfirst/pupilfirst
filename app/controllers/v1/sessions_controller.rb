class V1::SessionsController < V1::BaseController
  respond_to :json
  skip_before_filter :require_token, only: [:create]

  def create
    hash_string = "#{params[:timestamp]}#{APP_CONFIG[:login_secret]}#{params[:email]}"

    # Creating response
    @user = User.find_by email: params[:email]

    if not valid_request?(hash_string, params[:digest])
      render nothing: true, status: :unauthorized
    elsif @user.nil?
      raise Exceptions::LoginCredentialsInvalid, 'No user found with that email / password.'
    elsif not @user.valid_password?(params[:password])
      raise Exceptions::LoginCredentialsInvalid, 'No user found with that email / password.'
    end
  end

  private

  def valid_request?(hash_string, request_digest)
    Digest::SHA1.hexdigest(hash_string) == request_digest
  end
end
