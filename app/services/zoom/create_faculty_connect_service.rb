module Zoom
  class CreateFacultyConnectService
    def initialize(connect_request, mock: true)
      @connect_request = connect_request
      @mock = Rails.env.production? ? false : mock
    end

    def create
      return if @mock

      response = api_service.post(create_meeting_path, meeting_details)
      return JSON.parse(response.body) if response.code == 201

      raise "Unexpected response while creating Zoom meeting: #{response}"
    end

    private

    def api_service
      @api_service ||= Zoom::ApiService.new
    end

    def create_meeting_path
      host_user_id = Rails.application.secrets.zoom[:host_user_id]
      "users/#{host_user_id}/meetings"
    end

    def meeting_details
      {
        topic: topic,
        type: '2',
        start_time: @connect_request.slot_at.strftime('%Y-%m-%dT%H:%M:%S'),
        timezone: 'Asia/Calcutta',
        duration: '30',
        settings: {
          join_before_host: true,
          participant_video: true
        }
      }
    end

    def topic
      startup = @connect_request.startup.name
      faculty = @connect_request.faculty.name
      "#{startup} / #{faculty} (Office Hour)"
    end
  end
end
