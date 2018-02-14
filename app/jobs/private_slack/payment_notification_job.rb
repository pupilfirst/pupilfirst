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

    def payment(founder)
      @payment = Hash.new do |hash, key|
        hash[key] = key.payments.last
      end

      @payment[founder]
    end

    def payment_information(founder)
      amount = payment(founder).amount.round

      <<~PAYMENT_INFO
        <@U0299AQB5> We've just received first payment of *Rs. #{amount}* from a new team - *#{founder.startup.display_name}*.

        #{team_members_list(founder)}

        <https://www.sv.co/admin/startups/#{founder.startup.id}|View this team's details in the admin interface.>
      PAYMENT_INFO
    end

    def team_members_list(founder)
      team = founder.startup.founders.each_with_object([]) do |f, list|
        list << "#{team_member_string(f, list.count + 1)}#{founder.startup.team_lead == f ? ' - *Team Lead*' : ''}"
      end

      founder.startup.invited_founders.each do |f|
        team << "#{team_member_string(f, team.count + 1)} - *Invitation Pending*"
      end

      team.join("\n")
    end

    def team_member_string(founder, count)
      "#{count}. #{founder.name} :email: `#{founder.email}` :phone: #{founder.phone}"
    end
  end
end
