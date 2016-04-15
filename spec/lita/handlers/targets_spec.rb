require 'rails_helper'

require_relative '../../../lib/lita/handlers/targets'

# TODO: This spec uses squiggly / squished HEREDOC-s which is bugged on Ruby 2.3.0.
# Any problems related to messages will cause rspec to crash, without supplying correct error information.
# https://github.com/rspec/rspec-core/issues/2163
describe Lita::Handlers::Targets do
  describe '#targets_handler' do
    let(:response) { double 'Lita Response Object', match_data: ['targets'] }
    let(:founder) { create :founder_with_out_password }
    let(:slack_username_check_response) { { ok: true, members: [{ name: 'slack_username', id: 'ABCD1234' }] }.to_json }

    before do
      allow(response).to receive_message_chain(:message, :source, :user, :metadata).and_return('mention_name' => 'slack_username')
    end

    context 'when client is unknown' do
      it 'replies that slack username is not linked' do
        expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
          I'm sorry, but your slack mention name `@slack_username` isn't known to me.
          Please update your slack mention name on your SV.CO profile, and try asking me again.
        EXPECTED_REPLY

        subject.targets_handler(response)
      end
    end

    context 'when client is a known founder' do
      let(:startup) { create :startup }
      let(:founder) { create :founder_with_out_password, slack_username: 'slack_username' }

      # Create six targets to make sure only five are displayed.
      let(:expired_founder_target) { create :target, role: Target::ROLE_FOUNDER, assignee: founder, due_date: 2.days.ago }

      let(:complete_startup_target) do
        create :target, role: 'governance', assignee: startup, due_date: 1.week.ago, status: Target::STATUS_DONE
      end

      let(:expired_startup_target) { create :target, role: 'design', assignee: startup, due_date: 3.days.ago }
      let(:complete_founder_target) { create :target, role: Target::ROLE_FOUNDER, assignee: founder, due_date: 2.days.from_now, status: Target::STATUS_DONE }
      let(:pending_startup_target) { create :target, role: 'engineering', assignee: startup, due_date: 1.week.from_now }
      let(:pending_founder_target) { create :target, role: Target::ROLE_FOUNDER, assignee: founder, due_date: 2.weeks.from_now }

      before do
        # Disable verification of slack_username when founder is created.
        allow(RestClient).to receive(:get).and_return(slack_username_check_response)

        # Add founder to startup.
        startup.founders << founder

        # Memoize targets
        expired_founder_target
        complete_startup_target
        expired_startup_target
        complete_founder_target
        pending_startup_target
        pending_founder_target
      end

      context 'when asked for targets' do
        it 'replies with 5 most recent targets' do
          expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
            *1.* #{pending_founder_target.title} _(Pending - Due on #{pending_founder_target.due_date.strftime '%A, %b %d'})_
            *2.* #{pending_startup_target.title} _(Pending - Due on #{pending_startup_target.due_date.strftime '%A, %b %d'})_
            *3.* #{complete_founder_target.title} _(Done)_
            *4.* #{expired_startup_target.title} _(Expired)_
            *5.* #{complete_startup_target.title} _(Done)_
            Reply with `targets info [NUMBER]` for more information about a target.
          EXPECTED_REPLY

          subject.targets_handler(response)
        end
      end

      context 'when asked for information about specific target' do
        let(:response) { double 'Lita Response Object', match_data: %w(targets 1) }

        context 'when choice is valid' do
          it 'replies with basic information about target' do
            expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
              *#{pending_founder_target.title}*
              *Status:* Pending - Due on #{pending_founder_target.due_date.strftime '%A, %b %d'}
              *Role:* All Founders
              *Assigner:* #{pending_founder_target.assigner.name}
              *Description:* #{pending_founder_target.description}
            EXPECTED_REPLY

            subject.targets_handler(response)
          end

          context 'when target has additional optional info' do
            let(:pending_founder_target) do
              create :target,
                role: Target::ROLE_FOUNDER,
                assignee: founder,
                due_date: 2.weeks.from_now,
                completion_instructions: Faker::Lorem.sentence,
                resource_url: Faker::Internet.url
            end

            it 'replies with all available info' do
              expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
                *#{pending_founder_target.title}*
                *Status:* Pending - Due on #{pending_founder_target.due_date.strftime '%A, %b %d'}
                *Role:* All Founders
                *Assigner:* #{pending_founder_target.assigner.name}
                *Description:* #{pending_founder_target.description}
                *Completion Instructions:* #{pending_founder_target.completion_instructions}
                *Linked Resource:* <#{pending_founder_target.resource_url}|#{pending_founder_target.resource_url}>
              EXPECTED_REPLY

              subject.targets_handler(response)
            end
          end
        end

        context 'when choice is invalid' do
          let(:response) { double 'Lita Response Object', match_data: %w(targets 6) }

          it 'responds with an error message' do
            expect(response).to receive(:reply_privately).with(
              "I couldn't find your choice in my list of targets. It should be one of: `1, 2, 3, 4, 5`."
            )

            subject.targets_handler(response)
          end
        end
      end
    end
  end
end
