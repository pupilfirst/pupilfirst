module Keycloak
  class Client
    def endpoints
      @endpoints ||= Endpoints.new
    end

    def service_account
      @service_account ||= ServiceAccount.new
    end

    def fetch_user(email)
      uri = endpoints.admin_users
      uri.query = "search=#{email}"
      headers = { 'Authorization' => "Bearer #{service_account.access_token}" }
      res = Faraday.get(uri, nil, headers)
      if res.status == 200
        user = MultiJson.load(res.body).first
        user.presence || fail(res, "Failed to find user by email: #{email}")
      else
        fail(res, "Failed to find user by email: #{email}")
      end
    end

    def create_user(email, first_name, last_name)
      user_rep = {
        username: email,
        email: email,
        firstName: first_name,
        lastName: last_name,
        enabled: true
      }
      headers = {
        'Authorization' => "Bearer #{service_account.access_token}",
        'Content-Type' => 'application/json'
      }
      res = Faraday.post(endpoints.admin_users, user_rep.to_json, headers)
      if res.status == 201
        nil
      elsif res.status == 409
        body = MultiJson.load(res.body)
        Rails.logger.info(body['errorMessage'])
        nil
      else
        fail(res, 'Failed to create_user')
      end
    end

    def set_user_password(email, password)
      creds_rep = {
        type: "password",
        temporary: false,
        value: password
      }
      headers = {
        'Authorization' => "Bearer #{service_account.access_token}",
        'Content-Type' => 'application/json'
      }
      user = fetch_user(email)
      reset_password_uri = endpoints.admin_users
      reset_password_uri.path = reset_password_uri.path.concat("/#{user['id']}", '/reset-password')
      res = Faraday.put(reset_password_uri, creds_rep.to_json, headers)
      if res.status == 204
        nil
      else
        fail(res, 'Failed to set user password')
      end
    end

    def user_info(access_token)
      client_id = CONFIG[:client_id]
      client_secret = CONFIG[:client_secret]
      auth = Base64.strict_encode64("#{client_id}:#{client_secret}")
      headers = {
        'Authorization' => "Basic #{auth}",
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      payload = { 'token' => access_token }
      res = Faraday.post(endpoints.token_introspection, payload, headers)
      if res.status == 200
        MultiJson.load(res.body)
      else
        fail(res, 'Failed to fetch user_info')
      end
    end

    def user_signed_in?(access_token)
      user_info(access_token)['active']
    end

    def user_token(uname_email, password)
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      payload = {
        'client_id' => CONFIG[:client_id],
        'client_secret' => CONFIG[:client_secret],
        'username' => uname_email,
        'password' => password,
        'grant_type' => 'password'
      }
      res = Faraday.post(endpoints.token, payload, headers)
      if res.status == 200
        MultiJson.load(res.body)
      else
        fail(res, 'Failed to set user password')
      end
    end

    def user_sign_out(refresh_token)
      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      payload = {
        'client_id' => CONFIG[:client_id],
        'client_secret' => CONFIG[:client_secret],
        'refresh_token' => refresh_token
      }

      res = Faraday.post(endpoints.end_session, payload, headers)
      if res.status == 204
        true
      else
        fail(res, 'Failed to sign out user')
      end
    end

    def fail(response, message)
      raise FailedRequestError.new [message, response.status, response.body].map(:to_s).join(" - ")
    end
  end
end
