require 'rails_helper'

require_relative '../../../lib/lita/handlers/targets'

describe Lita::Handlers::Targets do
  # TODO: This spec is disabled because the handler needs to be updated to match latest program structure.
  describe '#targets_handler', disabled: true do
    let(:response) { double 'Lita Response Object', match_data: ['targets'] }
    let(:founder) { create :founder }
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
      let(:founder) { create :founder, slack_username: 'slack_username' }

      let(:complete_startup_target) do
        create :target, role: 'product', assignee: startup, status: Target::STATUS_DONE
      end

      let(:complete_founder_target) { create :target, role: Target::ROLE_STUDENT, assignee: founder, status: Target::STATUS_DONE }
      let(:pending_startup_target) { create :target, role: 'engineering', assignee: startup }
      let(:pending_founder_target) { create :target, role: Target::ROLE_STUDENT, assignee: founder }

      before do
        # Disable verification of slack_username when founder is created.
        allow(RestClient).to receive(:get).and_return(slack_username_check_response)

        # Add founder to startup.
        startup.founders << founder

        # Memoize targets
        complete_startup_target
        complete_founder_target
        pending_startup_target
        pending_founder_target
      end

      context 'when asked for targets' do
        it 'replies with 5 most recent targets' do
          expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
            *1.* #{pending_founder_target.title} _(Pending)_
            *2.* #{pending_startup_target.title} _(Pending)_
            *3.* #{complete_founder_target.title} _(Done)_
            *4.* #{complete_startup_target.title} _(Done)_
            Reply with `targets info [NUMBER]` for more information about a target.
          EXPECTED_REPLY

          subject.targets_handler(response)
        end
      end

      context 'when asked for information about specific target' do
        let(:response) { double 'Lita Response Object', match_data: %w[targets 1] }

        context 'when choice is valid' do
          it 'replies with basic information about target' do
            expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
              *#{pending_founder_target.title}*
              *Status:* Pending
              *Role:* All Founders
              *Coach:* #{pending_founder_target.faculty.name}
              *Description:* #{pending_founder_target.description}
            EXPECTED_REPLY

            subject.targets_handler(response)
          end

          context 'when target has additional optional info' do
            let(:pending_founder_target) do
              create :target,
                role: Target::ROLE_STUDENT,
                assignee: founder,
                completion_instructions: Faker::Lorem.sentence,
                resource_url: Faker::Internet.url
            end

            it 'replies with all available info' do
              shortened_url = ShortenedUrls::ShortenService.new(pending_founder_target.resource_url).shortened_url
              url_with_host = "https://sv.co/r/#{shortened_url.unique_key}"

              expect(response).to receive(:reply_privately).with <<~EXPECTED_REPLY
                *#{pending_founder_target.title}*
                *Status:* Pending
                *Role:* All Founders
                *Coach:* #{pending_founder_target.faculty.name}
                *Description:* #{pending_founder_target.description}
                *Completion Instructions:* #{pending_founder_target.completion_instructions}
                *Linked Resource:* <#{url_with_host}|#{url_with_host}>
              EXPECTED_REPLY

              subject.targets_handler(response)
            end
          end
        end

        context 'when choice is invalid' do
          let(:response) { double 'Lita Response Object', match_data: %w[targets 6] }

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
