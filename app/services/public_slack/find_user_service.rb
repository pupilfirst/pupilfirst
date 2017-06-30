module PublicSlack
  ApiFailedException = Class.new(StandardError)
  UserNotFoundException = Class.new(StandardError)

  class FindUserService
    def initialize(username)
      @username = username
    end

    def id
      index = usernames.index(@username)
      raise UserNotFoundException if index.blank?
      users[index]['id']
    end

    private

    def users
      @users ||= begin
        response_json = JSON.parse(RestClient.get("https://slack.com/api/users.list?token=#{Rails.application.secrets.slack_token}"))
        raise ApiFailedException unless response_json['ok']
        response_json['members']
      end
    end

    def usernames
      @usernames ||= users.map { |m| m['name'] }
    end
  end
end
