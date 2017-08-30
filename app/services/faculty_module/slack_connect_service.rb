module FacultyModule
  class SlackConnectService
    def initialize(faculty)
      @faculty = faculty
    end

    def slack_user_id
      response = api.get('users.list')

      valid_names = response['members'].map { |m| m['name'] }
      index = valid_names.index(@faculty.slack_username)

      index.present? ? response['members'][index]['id'] : nil
    end

    private

    def api
      PublicSlack::ApiService.new(token: Rails.application.secrets.slack.dig(:app, :bot_oauth_token))
    end
  end
end
