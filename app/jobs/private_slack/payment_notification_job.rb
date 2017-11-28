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

    def amount(founder)
      founder.payments.last.amount.round
    end

    def payment_information(founder)
      <<~PAYMENT_INFO
        <@U0299AQB5> We've just received first payment of *Rs. #{amount(founder)}* from a new team - *#{founder.startup.display_name}*

        ```
        #{team_members_list(founder)}
        ```

        <https://www.sv.co/admin/startups/#{founder.startup.id}|View this startup's details in the admin interface.>
      PAYMENT_INFO
    end

    def team_members_list(founder)
      Terminal::Table.new do |t|
        t << ['Name', 'Email', 'Phone Number', 'Notes']
        t << :separator

        founder.startup.founders.each do |f|
          t << [f.name, f.email, f.phone, founder.startup.team_lead == f ? 'Team Lead' : nil]
        end

        founder.startup.invited_founders.each do |f|
          t << [f.name, f.email, f.phone, 'Invitation Pending']
        end
      end.to_s
    end
  end
end
