module PrivateSlack
  # When a new team pays and joins the program, this job sends a notification to the #memberships channel.
  class PaymentNotificationJob < ApplicationJob
    queue_as :default

    def perform(founder)
      return if Rails.env.test?
      slack_webhook_url = Rails.application.secrets.slack_memberships_webhook_url
      json_payload = { text: payment_information(founder) }.to_json
      RestClient.post(slack_webhook_url, json_payload)
    end

    private

    def payment_information(founder)
      <<~PAYMENT_INFO
        @gemo We've just received first payment from a new team - #{founder.startup.display_name}

        *Team members:*
        #{team_members_list(founder)}

        <https://www.sv.co/admin/startups/#{founder.startup.id}|View this startup's details in the admin interface.>
      PAYMENT_INFO
    end

    def team_members_list(founder)
      counter = 0

      (founder.startup.founders.map do |f|
        counter += 1
        "#{counter}. `#{f.email}` #{f.name}#{founder.startup.team_lead == f ? ' (Team Lead)' : ''}"
      end + founder.startup.invited_founders.map do |f|
        counter += 1
        "#{counter}. `#{f.email}` #{f.name} (Invited)"
      end).join("\n")
    end
  end
end
