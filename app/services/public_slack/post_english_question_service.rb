module PublicSlack
  # Selects the 'English question for the day' and triggers a job to send it to all founders.
  class PostEnglishQuestionService
    include Loggable

    def post(target = nil)
      # Do nothing if we are out of questions.
      # TODO: Fallback to posting individual questions if so.
      return if question_for_the_day.blank?

      channels = target.presence || target_audience # The target argument is temporary - for testing.

      # Spin up a job for each channel to be pinged.
      channels.each do |channel|
        post_to_channel(channel)
        sleep 1
      end

      # Set the posted_on date for todays question.
      question_for_the_day.update!(posted_on: Date.today)
    end

    private

    def target_audience
      founder_slack_user_ids | faculty_slack_user_ids
    end

    # All founders with a slack_user_id.
    def founder_slack_user_ids
      Founder.where.not(slack_user_id: nil).pluck(:slack_user_id)
    end

    # All active team and alumni faculty with a slack_user_id
    def faculty_slack_user_ids
      Faculty.where(category: %w[team alumni]).where(inactive: false).where.not(slack_user_id: nil).pluck(:slack_user_id) + ['U0A6X5MEY'] # manually adding @manojmohan
    end

    # The oldest question which is not yet marked posted.
    def question_for_the_day
      @question_for_the_day ||= begin
        EnglishQuizQuestion.where(posted_on: nil).order(created_at: :asc).first
      end
    end

    # Format the question as valid slack message attachments.
    def question_as_slack_attachment
      [question_section, options_section].to_json
    end

    # The question details.
    def question_section
      {
        color: '#0F9D58',
        author_name: 'Manoj Mohan',
        author_link: 'https://www.sv.co/faculty/manoj-mohan',
        title: 'Daily English Quiz',
        text: 'Good Morning! Here is your question for today:',
        image_url: question_for_the_day.question_url,
        footer: Date.today.strftime('%b %d, %Y')
      }
    end

    # The answer options section.
    def options_section
      {
        callback_id: "english_quiz_#{question_for_the_day.id}",
        color: '#008AC1',
        text: 'Select your answer',
        actions: options_as_buttons
      }
    end

    # The answer options formatted as slack message buttons.
    def options_as_buttons
      question_for_the_day.answer_options.each_with_object([]) do |answer_option, buttons|
        buttons << { name: 'answer_option', type: 'button', text: answer_option.value, value: answer_option.id }
      end
    end

    # Post the question to the channel specefied.
    def post_to_channel(channel)
      params = { channel: channel, as_user: true, attachments: question_as_slack_attachment }
      response = api_service.get('chat.postMessage', params: params)
      log "Successfully posted English Question of the day to #{channel}" if response['ok']
    rescue PublicSlack::OperationFailureException
      nil # ignore Slack exceptions for now.
    end

    def api_service
      @api_service ||= begin
        token = Rails.application.secrets.slack.dig(:app, :bot_oauth_token)
        PublicSlack::ApiService.new(token: token)
      end
    end
  end
end
