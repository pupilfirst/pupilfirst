module PublicSlack
  ApiFailedException = Class.new(StandardError)

  class SendFileService
    def initialize(founder, content, filetype, filename)
      @founder = founder
      @content = content
      @filetype = filetype
      @filename = filename
      @token = Rails.application.secrets.slack_token
    end

    def execute
      return if Rails.env.development? || @founder.slack_user_id.blank?

      url = 'https://slack.com/api/files.upload'
      payload = { token: @token, channels: channel, content: @content, filetype: @filetype, filename: @filename }

      JSON.parse RestClient.post(url, payload)
    end

    private

    def channel
      im_id_response = JSON.parse RestClient.get("https://slack.com/api/im.open?token=#{@token}&user=#{@founder.slack_user_id}")
      raise ApiFailedException unless im_id_response['ok']

      im_id_response['channel']['id']
    end
  end
end
